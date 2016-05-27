module App.Update exposing ( update )

import App.App                                            exposing (App)
import App.Messages                                       exposing (Msg(..))
import App.Products.Product         as P                  exposing (Product)
import App.Products.Forms.ViewModel as CPF                exposing (CreateProductForm)
import App.Products.Forms.Update    as CPF
import App.Products.Navigation      as Navigation
import App.Products.Messages        as P
import App.Products.Show.ViewModel  as PV                 exposing (ProductView)
import App.Products.Show.Update     as PV
import CoreExtensions.Maybe                               exposing (fromJust)
import Data.External                                      exposing (External(..))
import Http as Http                                       exposing (Error)
import Debug exposing (log)

update : Msg -> App -> (App, Cmd Msg)
update action app =
  case log "App.Update - action: " action of
    NavigationActions  navAction         -> processNavigationAction navAction app
    -- ProductFormActions productFormAction -> processFormAction productFormAction app
    ProductViewActions productViewAction -> processProductViewAction productViewAction app
    FetchProductsSucceeded products      -> handleProductsLoaded products app
    FetchProductsFailed err              -> showError err app
    CreateProductsSucceeded product      -> addNewProduct product app
    SetName _                            -> processFormAction action app
    SetRepositoryUrl _                   -> processFormAction action app
    SubmitForm                           -> processFormAction action app
    _                                    -> log "App.Update: ignoring..." (app, Cmd.none)


handleProductsLoaded : List Product -> App -> (App, Cmd Msg)
handleProductsLoaded products app =
  case products of
    []     -> setCreateProductView app products
    p::_   -> setProductView app products p

showError : Error -> App -> (App, Cmd Msg)
showError _ app =
  let newState = setErrorView app "Error loading products"
  in
    (newState, Cmd.none)

processProductViewAction : P.Msg -> App -> (App, Cmd Msg)
processProductViewAction productViewAction app =
  case creatingNewProduct productViewAction of
    True  -> showNewProductForm productViewAction app
    False -> forwardToProductView productViewAction app

showNewProductForm : P.Msg -> App -> (App, Cmd Msg)
showNewProductForm productViewAction app =
  let (newProductView, fx) = PV.update productViewAction (fromJust app.productView) (fromJust app.appConfig)
      newState = { app | productView = Just newProductView
                       , currentView = Navigation.CreateProductFormView
                 }
  in
    (newState, Cmd.map ProductViewActions fx)

forwardToProductView : P.Msg -> App -> (App, Cmd Msg)
forwardToProductView  productViewAction app =
  let (newProductView, fx) = PV.update productViewAction (fromJust app.productView) (fromJust app.appConfig)
      newState = { app | productView = Just newProductView }
  in
    (newState, Cmd.map ProductViewActions fx)

creatingNewProduct : P.Msg -> Bool
creatingNewProduct productViewAction =
  case productViewAction of
    P.NavBarAction navBarAction ->
      navBarAction == Navigation.ShowCreateNewProductForm
    _ -> False

setErrorView : App -> String -> App
setErrorView app err =
  { app | products    = LoadedWithError err
        , currentView = Navigation.ErrorView err
  }

setCreateProductView : App -> List Product -> (App, Cmd Msg)
setCreateProductView app products =
  ( { app | products    = Loaded products
          , currentView = Navigation.CreateProductFormView
    }
  , Cmd.none
  )

setProductView : App -> List Product -> Product -> (App, Cmd Msg)
setProductView app products selectedProduct =
  let (productView, fx) = log "setProductView" PV.init (fromJust app.appConfig) products selectedProduct
  in
    (,)
    { app | products    = Loaded products
          , productView = Just productView
          , currentView = Navigation.ProductView
    }
    (Cmd.map ProductViewActions fx)



processNavigationAction : Navigation.Action -> App -> (App, Cmd Msg)
processNavigationAction navAction app =
  case app.productView of
    Nothing -> (app, Cmd.none)
    Just pv ->
      let (newProductView, fx) = PV.update (P.NavBarAction navAction) pv (fromJust app.appConfig)
      in
        ( { app | productView = Just newProductView }
        , Cmd.map ProductViewActions fx
        )

addNewProduct : Product -> App -> (App, Cmd Msg)
addNewProduct product app =
  let (newProductView, fx) = PV.init (fromJust app.appConfig) (extractProducts app.products) product
  in
    ( { app | currentView = Navigation.ProductView
            , productView = Just newProductView
            , productForm = CPF.init P.newProduct
      }
    , Cmd.map ProductViewActions fx
    )

processFormAction : Msg -> App -> (App, Cmd Msg)
processFormAction formAction app =
  let (newCreateProductForm, fx) = CPF.update formAction app.productForm (fromJust app.appConfig)
  in
    ( { app | productForm = newCreateProductForm }
    , fx
    )

-- processFormAction : P.Msg -> App -> (App, Cmd Msg)
-- processFormAction formAction app =
  -- let (newCreateProductForm, fx) = CPF.update formAction app.productForm (fromJust app.appConfig)
      -- newApp = { app | productForm = newCreateProductForm }
  -- in
    -- (newApp, fx)
  -- case formAction of
    -- P.NewProductCreated product ->
      -- let (newProductView, fx) = PV.init (fromJust app.appConfig) (extractProducts app.products) product
          -- newApp = { app | currentView = Navigation.ProductView
                         -- , productView = Just newProductView
                         -- , productForm = CPF.init P.newProduct
                   -- }
      -- in
        -- (newApp, Cmd.map ProductViewActions fx)
    -- _ ->
      -- let (newCreateProductForm, fx) = CPF.update formAction app.productForm (fromJust app.appConfig)
          -- newApp = { app | productForm = newCreateProductForm }
      -- in
        -- (newApp, Cmd.map ProductFormActions fx)

extractProducts : External (List Product) -> List Product
extractProducts exData =
  case exData of
    Loaded products -> products
    _ -> []
