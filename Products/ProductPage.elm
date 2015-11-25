module Products.ProductPage where

import CoreExtensions.Maybe              exposing (..)
import Debug                             exposing (crash)
import Effects                           exposing (Effects)
import Html                              exposing (Html)
import Http as Http                      exposing (..)
import List                              exposing (head, length)
import Products.Product as P             exposing (Product)
import Products.CreateProductForm as CPF exposing (CreateProductForm)
import Products.ProductView as PV        exposing (ProductView)
import Products.Navigation as Nav
import Task as Task                      exposing (..)

type alias ProductPage =
  { createProductForm : CreateProductForm
  , productView : Maybe ProductView
  , selectedView : ViewOptions
  }

type Action = ProductViewAction PV.Action
            | CreateProductFormAction CPF.Action
            | UpdateProducts (Result Error (List Product))

type ViewOptions = CreateProductsFormOption
                 | ProductViewOption

productsEndpoint = "http://localhost:8081/products"

init : (ProductPage, Effects Action)
init = ( { createProductForm = CPF.init
         , productView = Nothing
         , selectedView = CreateProductsFormOption
         }
       , getProducts productsEndpoint
       )

update : Action -> ProductPage -> (ProductPage, Effects Action)
update action productPage = case action of
  UpdateProducts resultProducts ->
    case resultProducts of
      Ok products ->
        case initialView products of
          ProductViewOption -> showProductView productPage products (fromJust << head <| products)
          CreateProductsFormOption -> showCreateProductForm productPage
      Err _ ->
        crash "Error: Failed to load Products"

  ProductViewAction prodViewAction ->
    case showingProductCreationForm prodViewAction of
      True ->
        ( { productPage | selectedView <- CreateProductsFormOption }
        , Effects.none
        )
      False ->
        updateProductView productPage prodViewAction

  CreateProductFormAction createProdFormAction ->
    let (createProdForm, createProdFormFx) = CPF.update createProdFormAction productPage.createProductForm
    in ( { productPage | createProductForm <- createProdForm }
       , Effects.map CreateProductFormAction createProdFormFx
       )

initialView : List Product -> ViewOptions
initialView products =
  case length products > 0 of
    True  -> ProductViewOption
    False -> CreateProductsFormOption

showProductView : ProductPage -> List Product -> Product -> (ProductPage, Effects Action)
showProductView productPage products selectedProduct =
  let (prodView, prodViewFx) = (PV.init products selectedProduct)
  in ( { productPage |
         productView <- Just prodView
       , selectedView <- ProductViewOption
       }
     , Effects.map ProductViewAction prodViewFx
     )

showCreateProductForm : ProductPage -> (ProductPage, Effects Action)
showCreateProductForm productPage =
  ( { productPage | selectedView <- CreateProductsFormOption }
  , Effects.none
  )

updateProductView : ProductPage -> PV.Action -> (ProductPage, Effects Action)
updateProductView productPage prodViewAction =
  case productPage.productView of
    Just productView ->
      let (prodView, fx) = PV.update prodViewAction productView
      in ( { productPage | productView <- Just prodView }
         , Effects.map ProductViewAction fx
         )
    Nothing -> (productPage, Effects.none)

showingProductCreationForm : PV.Action -> Bool
showingProductCreationForm prodViewAction =
  case prodViewAction of
    PV.NavBarAction navBarAction ->
      case navBarAction of
        Nav.ShowCreateNewProductForm -> True
        _                            -> False
    _ -> False

view : Signal.Address Action -> ProductPage -> Html
view address productPage =
  case productPage.selectedView of
    CreateProductsFormOption ->
      let forwardedAddress = (Signal.forwardTo address CreateProductFormAction)
          productFormHtml = CPF.view forwardedAddress
      in Html.div [] [ productFormHtml ]
    ProductViewOption ->
      case productPage.productView of
        Just productView -> renderProductViewView address productView
        Nothing          -> Html.text "No products found"

renderProductViewView : Signal.Address Action -> ProductView -> Html
renderProductViewView address productView =
  let forwardedAddress = (Signal.forwardTo address ProductViewAction)
      productViewHtml = PV.view forwardedAddress productView
  in Html.div [] [ productViewHtml ]

getProducts : String -> Effects Action
getProducts url =
   Http.get P.parseProducts url
    |> Task.toResult
    |> Task.map UpdateProducts
    |> Effects.task
