module App.App where

import App.AppConfig                                      exposing (..)
import App.Products.Product         as P                  exposing (Product)
import App.Products.Forms.Actions   as ProductFormActions
import App.Products.Forms.ViewModel as CPF                exposing (CreateProductForm)
import App.Products.Forms.View      as CPF
import App.Products.Forms.Update    as CPF
import App.Products.Navigation      as Navigation
import App.Products.Show.Actions    as ProductViewActions
import App.Products.Show.ViewModel  as PV                 exposing (ProductView)
import App.Products.Show.View       as PV
import App.Products.Show.Update     as PV
import CoreExtensions.Maybe                               exposing (fromJust)
import Data.External                                      exposing (External(..))
import Effects                                            exposing (Effects)
import Html                                               exposing (Html)
import Http as Http                                       exposing (Error)
import List                                               exposing (head, length)

type alias App =
  { appConfig   : Maybe AppConfig
  , products    : External (List Product)
  , currentView : Navigation.CurrentView
  , productForm : CreateProductForm
  , productView : Maybe ProductView
  }

type Action = ProductsLoaded (Result Error (List Product))
            | ConfigLoaded AppConfig
            | ProductFormActions ProductFormActions.Action
            | ProductViewActions ProductViewActions.Action
            | NavigationActions Navigation.Action

init : (App, Effects Action)
init =
  let initialState = { appConfig   = Nothing
                     , products    = NotLoaded
                     , currentView = Navigation.LoadingView
                     , productForm = CPF.init
                     , productView = Nothing
                     }
  in
    (initialState, Effects.none)

update : Action -> App -> (App, Effects Action)
update action app =
  case action of
    ConfigLoaded appConfig               -> processAppConfig appConfig app
    NavigationActions  navAction         -> processNavigationAction navAction app
    ProductFormActions productFormAction -> processFormAction productFormAction app
    ProductViewActions productViewAction -> processProductViewAction productViewAction app
    ProductsLoaded resultProducts        -> processProductsResponse resultProducts app

view : Signal.Address Action -> App -> Html
view address app =
  case app.currentView of
    Navigation.LoadingView           -> renderLoadingView
    Navigation.ErrorView err         -> renderErrorView err
    Navigation.CreateProductFormView -> renderProductsForm address app
    Navigation.ProductView           -> renderProductView address app
    Navigation.DomainTermsView       -> renderProductView address app
    Navigation.UserRolesView         -> renderProductView address app

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
    Nothing -> Html.div [] [ Html.text "No products found" ]
    Just pv ->
      let forwardedAddress = (Signal.forwardTo address ProductViewActions)
          productViewHtml  = PV.view forwardedAddress pv
      in Html.div [] [ productViewHtml ]

setProductView : App -> List Product -> Product -> (App, Effects Action)
setProductView app products selectedProduct =
  let (productView, fx) = PV.init (fromJust app.appConfig) products selectedProduct
  in
    ( { app | products    = Loaded products
            , productView = Just productView
            , currentView = Navigation.ProductView
      }
    , Effects.map ProductViewActions fx
    )

setCreateProductView : App -> List Product -> (App, Effects Action)
setCreateProductView app products =
  ( { app | products    = Loaded products
          , currentView = Navigation.CreateProductFormView
    }
  , Effects.none
  )

setErrorView : App -> String -> App
setErrorView app err =
  { app | products    = LoadedWithError err
        , currentView = Navigation.ErrorView err
  }


processAppConfig : AppConfig -> App -> (App, Effects Action)
processAppConfig appConfig app =
  ({ app | appConfig = Just appConfig }, P.getProducts appConfig ProductsLoaded)


-- product response action handler

processProductsResponse : Result Error (List Product) -> App -> (App, Effects Action)
processProductsResponse result app =
  case result of
    Ok products ->
      let selectedProduct = head products
          (newState, fx) = case selectedProduct of
            Just p  -> setProductView app products p
            Nothing -> setCreateProductView app products
      in
        (newState, fx)
    Err err ->
      let newState = setErrorView app "Error loading products"
      in
        (newState, Effects.none)


-- product view action handler

processProductViewAction : ProductViewActions.Action -> App -> (App, Effects Action)
processProductViewAction productViewAction app =
  case creatingNewProduct productViewAction of
    True  -> showNewProductForm productViewAction app
    False -> forwardToProductView productViewAction app


creatingNewProduct : ProductViewActions.Action -> Bool
creatingNewProduct productViewAction =
  case productViewAction of
    ProductViewActions.NavBarAction navBarAction ->
      navBarAction == Navigation.ShowCreateNewProductForm
    _ -> False

showNewProductForm : ProductViewActions.Action -> App -> (App, Effects Action)
showNewProductForm productViewAction app =
  let (newProductView, fx) = PV.update productViewAction (fromJust app.productView) (fromJust app.appConfig)
      newState = { app | productView = Just newProductView
                       , currentView = Navigation.CreateProductFormView
                 }
  in
    (newState, Effects.map ProductViewActions fx)

forwardToProductView : ProductViewActions.Action -> App -> (App, Effects Action)
forwardToProductView  productViewAction app =
  let (newProductView, fx) = PV.update productViewAction (fromJust app.productView) (fromJust app.appConfig)
      newState = { app | productView = Just newProductView }
  in
    (newState, Effects.map ProductViewActions fx)


-- nav action handler

processNavigationAction : Navigation.Action -> App -> (App, Effects Action)
processNavigationAction navAction app =
  case app.productView of
    Nothing -> (app, Effects.none)
    Just pv ->
      let (newProductView, fx) = PV.update (ProductViewActions.NavBarAction navAction) pv (fromJust app.appConfig)
          newApp = { app | productView = Just newProductView }
      in
        (newApp, Effects.map ProductViewActions fx)


-- form action handler

extractProducts : External (List Product) -> List Product
extractProducts exData =
  case exData of
    Loaded products -> products
    _ -> []

processFormAction : ProductFormActions.Action -> App -> (App, Effects Action)
processFormAction formAction app =
  case formAction of
    ProductFormActions.NewProductCreated product ->
      let (newProductView, fx) = PV.init (fromJust app.appConfig) (extractProducts app.products) product
          newApp = { app | currentView = Navigation.ProductView
                         , productView = Just newProductView
                         , productForm = CPF.init
                   }
      in
        (newApp, Effects.map ProductViewActions fx)
    _ ->
      let (newCreateProductForm, fx) = CPF.update formAction app.productForm
          newApp = { app | productForm = newCreateProductForm }
      in
        (newApp, Effects.map ProductFormActions fx)
