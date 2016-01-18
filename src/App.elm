module App where

import CoreExtensions.Maybe            exposing (fromJust)
import Debug                           exposing (log)
import Effects                         exposing (Effects)
import Html                            exposing (Html)
import Http as Http                    exposing (..)
import List                            exposing (head, length)
import Products.Product         as P   exposing (Product)
import Products.Forms.Actions   as ProductFormActions
import Products.Forms.ViewModel as CPF exposing (CreateProductForm)
import Products.Forms.View      as CPF
import Products.Forms.Update    as CPF
import Products.Show.Actions    as ProductViewActions
import Products.Show.ViewModel  as PV  exposing (ProductView)
import Products.Show.View       as PV
import Products.Show.Update     as PV
import Task as Task                    exposing (..)

type alias App =
  { products          : ExternalData (List Product)
  , currentView       : CurrentView
  , productForm       : CreateProductForm
  , productView       : Maybe ProductView
  }

type Action = UpdateProducts (Result Error (List Product))
            | ProductFormActions ProductFormActions.Action
            | ProductViewActions ProductViewActions.Action

type ExternalData a = NotLoaded
                    | Loaded a
                    | LoadedWithError String

type CurrentView = LoadingView
                 | ErrorView String
                 | CreateProductsFormView
                 | ProductView

init : (App, Effects Action)
init =
  let initialState = { products    = NotLoaded
                     , currentView = LoadingView
                     , productForm = CPF.init
                     , productView = Nothing
                     }
  in
    (initialState, getProducts productsEndpoint)

update : Action -> App -> (App, Effects Action)
update action app =
  case action of
    ProductFormActions productFormAction ->
      let (newCreateProductForm, fx) = CPF.update productFormAction app.productForm
          newState = { app | productForm = newCreateProductForm }
      in
        (newState, Effects.map ProductFormActions fx)
    ProductViewActions productViewAction ->
      let (newProductView, fx) = PV.update productViewAction (fromJust app.productView)
          newState = { app | productView = Just newProductView }
      in
        (newState, Effects.map ProductViewActions fx)
    UpdateProducts resultProducts ->
      case resultProducts of
        Ok products ->
          let selectedProduct = head products
              (newState, fx) = case selectedProduct of
                Just p  ->
                  setProductView app products p
                Nothing ->
                  setCreateProductView app products
          in
            (newState, fx)
        Err err ->
          let loggedErr = log "Error: " err
              newState = setErrorView app "Error loading products"
          in
            (newState, Effects.none)

setProductView : App -> List Product -> Product -> (App, Effects Action)
setProductView app products selectedProduct =
  let (productView, fx) = PV.init products selectedProduct
  in
    ( { app | products    = Loaded products
            , productView = Just productView
            , currentView = ProductView
      }
    , Effects.map ProductViewActions fx
    )

setCreateProductView : App -> List Product -> (App, Effects Action)
setCreateProductView app products =
  ( { app | products    = Loaded products
          , currentView = CreateProductsFormView
    }
  , Effects.none
  )

setErrorView : App -> String -> App
setErrorView app err =
  { app | products    = LoadedWithError err
        , currentView = ErrorView err
  }

view : Signal.Address Action -> App -> Html
view address app =
  case app.currentView of
    LoadingView            -> renderLoadingView
    ErrorView err          -> renderErrorView err
    CreateProductsFormView -> renderProductsForm address app
    ProductView            -> renderProductView address app

renderLoadingView : Html
renderLoadingView = Html.div [] [ Html.text "loading..." ]

renderErrorView : String -> Html
renderErrorView err = Html.div [] [ Html.text err ]

renderProductsForm : Signal.Address Action -> App -> Html
renderProductsForm address app =
  let forwardedAddress  = (Signal.forwardTo address ProductFormActions)
      productForm = CPF.init
      productFormHtml   = CPF.view forwardedAddress productForm
  in Html.div [] [ productFormHtml ]

renderProductView : Signal.Address Action -> App -> Html
renderProductView address app =
  case app.productView of
    Nothing          -> Html.div [] [ Html.text "No products found" ]
    Just pv ->
      let forwardedAddress = (Signal.forwardTo address ProductViewActions)
          productViewHtml  = PV.view forwardedAddress pv
      in Html.div [] [ productViewHtml ]

getProducts : String -> Effects Action
getProducts url =
   Http.get P.parseProducts url
    |> Task.toResult
    |> Task.map UpdateProducts
    |> Effects.task

productsEndpoint : String
productsEndpoint = "http://localhost:8081/products"
