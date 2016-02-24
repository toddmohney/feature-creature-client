module App.Update
  ( update
  ) where

import App.Actions exposing (Action (..))
import App.App                                            exposing (App)
import App.AppConfig                                      exposing (..)
import App.Products.Product         as P                  exposing (Product)
import App.Products.Requests        as P
import App.Products.Forms.Actions   as ProductFormActions
import App.Products.Forms.ViewModel as CPF                exposing (CreateProductForm)
import App.Products.Forms.Update    as CPF
import App.Products.Navigation      as Navigation
import App.Products.Show.Actions    as ProductViewActions
import App.Products.Show.ViewModel  as PV                 exposing (ProductView)
import App.Products.Show.Update     as PV
import CoreExtensions.Maybe                               exposing (fromJust)
import Data.External                                      exposing (External(..))
import Effects                                            exposing (Effects)
import Http as Http                                       exposing (Error)
import List                                               exposing (head, length)

update : Action -> App -> (App, Effects Action)
update action app =
  case action of
    ConfigLoaded appConfig               -> processAppConfig appConfig app
    NavigationActions  navAction         -> processNavigationAction navAction app
    ProductFormActions productFormAction -> processFormAction productFormAction app
    ProductViewActions productViewAction -> processProductViewAction productViewAction app
    ProductsLoaded resultProducts        -> processProductsResponse resultProducts app

processAppConfig : AppConfig -> App -> (App, Effects Action)
processAppConfig appConfig app =
  (,)
  { app | appConfig = Just appConfig }
  (P.getProducts appConfig ProductsLoaded)

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

processProductViewAction : ProductViewActions.Action -> App -> (App, Effects Action)
processProductViewAction productViewAction app =
  case creatingNewProduct productViewAction of
    True  -> showNewProductForm productViewAction app
    False -> forwardToProductView productViewAction app

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

creatingNewProduct : ProductViewActions.Action -> Bool
creatingNewProduct productViewAction =
  case productViewAction of
    ProductViewActions.NavBarAction navBarAction ->
      navBarAction == Navigation.ShowCreateNewProductForm
    _ -> False

setErrorView : App -> String -> App
setErrorView app err =
  { app | products    = LoadedWithError err
        , currentView = Navigation.ErrorView err
  }

setCreateProductView : App -> List Product -> (App, Effects Action)
setCreateProductView app products =
  ( { app | products    = Loaded products
          , currentView = Navigation.CreateProductFormView
    }
  , Effects.none
  )

setProductView : App -> List Product -> Product -> (App, Effects Action)
setProductView app products selectedProduct =
  let (productView, fx) = PV.init (fromJust app.appConfig) products selectedProduct
  in
    (,) 
    { app | products    = Loaded products
          , productView = Just productView
          , currentView = Navigation.ProductView
    }
    (Effects.map ProductViewActions fx)



processNavigationAction : Navigation.Action -> App -> (App, Effects Action)
processNavigationAction navAction app =
  case app.productView of
    Nothing -> (app, Effects.none)
    Just pv ->
      let (newProductView, fx) = PV.update (ProductViewActions.NavBarAction navAction) pv (fromJust app.appConfig)
          newApp = { app | productView = Just newProductView }
      in
        (newApp, Effects.map ProductViewActions fx)


processFormAction : ProductFormActions.Action -> App -> (App, Effects Action)
processFormAction formAction app =
  case formAction of
    ProductFormActions.NewProductCreated product ->
      let (newProductView, fx) = PV.init (fromJust app.appConfig) (extractProducts app.products) product
          newApp = { app | currentView = Navigation.ProductView
                         , productView = Just newProductView
                         , productForm = CPF.init P.newProduct
                   }
      in
        (newApp, Effects.map ProductViewActions fx)
    _ ->
      let (newCreateProductForm, fx) = CPF.update formAction app.productForm (fromJust app.appConfig)
          newApp = { app | productForm = newCreateProductForm }
      in
        (newApp, Effects.map ProductFormActions fx)

extractProducts : External (List Product) -> List Product
extractProducts exData =
  case exData of
    Loaded products -> products
    _ -> []
