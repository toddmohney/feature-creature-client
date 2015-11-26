module Products.ProductPage where

import CoreExtensions.Effects            exposing (batchEffects)
import CoreExtensions.Maybe              exposing (..)
import CoreExtensions.Writer             exposing (Writer, (>>=), runWriter)
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

type alias ProductPageResult =
  (ProductPage, Effects Action)

type alias CreateProductFormResult =
  (ProductPage, CPF.Action)

type Action = ProductViewAction PV.Action
            | CreateProductFormAction CPF.Action
            | UpdateProducts (Result Error (List Product))

type alias CreateProductFormWriter =
  Writer CreateProductFormResult (List (Effects Action))

type ViewOptions = CreateProductsFormOption
                 | ProductViewOption

productsEndpoint = "http://localhost:8081/products"

init : ProductPageResult
init = ( { createProductForm = CPF.init
         , productView = Nothing
         , selectedView = CreateProductsFormOption
         }
       , getProducts productsEndpoint
       )

update : Action -> ProductPage -> ProductPageResult
update action productPage = case action of
  UpdateProducts resultProducts ->
    case resultProducts of
      Ok products ->
        case initialView products of
          ProductViewOption ->
            initProductView productPage products (fromJust << head <| products)
          CreateProductsFormOption ->
            showCreateProductForm productPage
      Err _ ->
        crash "Error: Failed to load Products"

  ProductViewAction prodViewAction ->
    case showingProductCreationForm prodViewAction of
      True ->
        ( { productPage |
            selectedView = CreateProductsFormOption
          , createProductForm = CPF.init
          }
        , Effects.none
        )
      False ->
        updateProductView productPage prodViewAction

  CreateProductFormAction createProdFormAction ->
    let ((updatedProductPage, _), effects) = runWriter <| updateCreateProductForm (productPage, createProdFormAction) >>= addNewProduct
    in (updatedProductPage, batchEffects effects)

updateCreateProductForm : (ProductPage, CPF.Action) -> CreateProductFormWriter
updateCreateProductForm (productPage, createProductFormAction) =
  let createProductForm                  = productPage.createProductForm
      (createProdForm, createProdFormFx) = CPF.update createProductFormAction createProductForm
      updatedProductPage                 = { productPage | createProductForm = createProdForm }
      effects = if createProdFormFx == Effects.none
               then []
               else [ Effects.map CreateProductFormAction createProdFormFx ]
  in { output = (updatedProductPage, createProductFormAction)
     , log = effects
     }

addNewProduct : (ProductPage, CPF.Action) -> CreateProductFormWriter
addNewProduct (productPage, createProductFormAction) =
  case createProductFormAction of
    CPF.AddNewProduct result ->
      -- is there some other way we can create a new Effect
      -- so that this module doesn't have to concern itself
      -- with the HTTP request? I'd like to react to an `AddNewProduct Product`
      -- effect which hides the implementation of how we got that new product
      case result of
        Ok newProduct ->
          let updatedProducts = (getProductList productPage) ++ [newProduct]
              (updatedProductPage, effect) = initProductView productPage updatedProducts newProduct
              createProductFormResult = ( { updatedProductPage | selectedView = ProductViewOption }
                                        , createProductFormAction
                                        )
              effects = if effect == Effects.none
                        then []
                        else [ effect ]
          in { output = createProductFormResult, log = effects }
        Err _ ->
          crash "Failed to create new product"
    _ -> -- noop
      { output = (productPage, createProductFormAction)
      , log = []
      }

getProductList : ProductPage -> List Product
getProductList productPage =
  case productPage.productView of
    Just productView -> productView.navBar.products
    Nothing -> []

initialView : List Product -> ViewOptions
initialView products =
  case length products > 0 of
    True  -> ProductViewOption
    False -> CreateProductsFormOption

view : Signal.Address Action -> ProductPage -> Html
view address productPage =
  case productPage.selectedView of
    CreateProductsFormOption ->
      let forwardedAddress = (Signal.forwardTo address CreateProductFormAction)
          productFormHtml = CPF.view forwardedAddress
      in Html.div [] [ productFormHtml ]
    ProductViewOption ->
      case productPage.productView of
        Just productView -> renderProductView address productView
        Nothing          -> Html.text "No products found"

initProductView : ProductPage -> List Product -> Product -> ProductPageResult
initProductView productPage products selectedProduct =
  let (prodView, prodViewFx) = (PV.init products selectedProduct)
  in ( { productPage |
         productView = Just prodView
       , selectedView = ProductViewOption
       }
     , Effects.map ProductViewAction prodViewFx
     )

updateProductView : ProductPage -> PV.Action -> ProductPageResult
updateProductView productPage prodViewAction =
  case productPage.productView of
    Just productView ->
      let (prodView, fx) = PV.update prodViewAction productView
      in ( { productPage | productView = Just prodView }
         , Effects.map ProductViewAction fx
         )
    Nothing -> (productPage, Effects.none)

renderProductView : Signal.Address Action -> ProductView -> Html
renderProductView address productView =
  let forwardedAddress = (Signal.forwardTo address ProductViewAction)
      productViewHtml = PV.view forwardedAddress productView
  in Html.div [] [ productViewHtml ]

showingProductCreationForm : PV.Action -> Bool
showingProductCreationForm prodViewAction =
  case prodViewAction of
    PV.NavBarAction navBarAction ->
      case navBarAction of
        Nav.ShowCreateNewProductForm -> True
        _                            -> False
    _ -> False

showCreateProductForm : ProductPage -> ProductPageResult
showCreateProductForm productPage =
  ( { productPage | selectedView = CreateProductsFormOption }
  , Effects.none
  )

getProducts : String -> Effects Action
getProducts url =
   Http.get P.parseProducts url
    |> Task.toResult
    |> Task.map UpdateProducts
    |> Effects.task
