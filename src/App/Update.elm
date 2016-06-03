module App.Update exposing ( update )

import App.App                                    exposing (App)
import App.Messages                               exposing (Msg(..))
import App.Products.Product         as P          exposing (Product)
import App.Products.Forms.ViewModel as CPF        exposing (CreateProductForm)
import App.Products.Forms.Update    as CPF
import App.Products.Navigation      as Navigation
import App.Products.Messages        as P
import App.Products.Show.ViewModel  as PV         exposing (ProductView)
import App.Products.Show.Update     as PV
import Auth
import CoreExtensions.Maybe                       exposing (fromJust)
import Data.External                              exposing (External(..))
import Http as Http                               exposing (Error)
import Debug exposing (crash)

update : Msg -> App -> (App, Cmd Msg)
update msg app =
  case msg of
    NavigationMsgs  navMsg         -> processNavigationMsg navMsg app
    ProductViewMsgs productViewMsg -> processProductViewMsg productViewMsg app
    FetchProductsSucceeded products      -> handleProductsLoaded products app
    FetchProductsFailed err              -> showError err app
    CreateProductsSucceeded product      -> addNewProduct product app
    SetName _                            -> processFormMsg msg app
    SetRepositoryUrl _                   -> processFormMsg msg app
    SubmitForm                           -> processFormMsg msg app
    AuthenticationMsgs msg            -> processAuthenticationMsg msg app
    CreateProductsFailed _               -> crash "Unable to create new product"

processAuthenticationMsg : Auth.Msg -> App -> (App, Cmd Msg)
processAuthenticationMsg (Auth.AuthorizationCodeReceived code) app = (app, Cmd.none)

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

processProductViewMsg : P.Msg -> App -> (App, Cmd Msg)
processProductViewMsg productViewMsg app =
  case creatingNewProduct productViewMsg of
    True  -> showNewProductForm productViewMsg app
    False -> forwardToProductView productViewMsg app

showNewProductForm : P.Msg -> App -> (App, Cmd Msg)
showNewProductForm productViewMsg app =
  let (newProductView, fx) = PV.update productViewMsg (fromJust app.productView) app.appConfig
      newState = { app | productView = Just newProductView
                       , currentView = Navigation.CreateProductFormView
                 }
  in
    (newState, Cmd.map ProductViewMsgs fx)

forwardToProductView : P.Msg -> App -> (App, Cmd Msg)
forwardToProductView  productViewMsg app =
  let (newProductView, fx) = PV.update productViewMsg (fromJust app.productView) app.appConfig
      newState = { app | productView = Just newProductView }
  in
    (newState, Cmd.map ProductViewMsgs fx)

creatingNewProduct : P.Msg -> Bool
creatingNewProduct productViewMsg =
  case productViewMsg of
    P.NavBarMsg navBarMsg ->
      navBarMsg == Navigation.ShowCreateNewProductForm
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
  let (productView, fx) = PV.init app.appConfig products selectedProduct
  in
    ( { app | products    = Loaded products
      , productView = Just productView
      , currentView = Navigation.ProductView
      }
    , Cmd.map ProductViewMsgs fx
    )

processNavigationMsg : Navigation.Msg -> App -> (App, Cmd Msg)
processNavigationMsg navMsg app =
  case app.productView of
    Nothing -> (app, Cmd.none)
    Just pv ->
      let (newProductView, fx) = PV.update (P.NavBarMsg navMsg) pv app.appConfig
      in
        ( { app | productView = Just newProductView }
        , Cmd.map ProductViewMsgs fx
        )

addNewProduct : Product -> App -> (App, Cmd Msg)
addNewProduct product app =
  let (newProductView, fx) = PV.init app.appConfig (extractProducts app.products) product
  in
    ( { app | currentView = Navigation.ProductView
            , productView = Just newProductView
            , productForm = CPF.init P.newProduct
      }
    , Cmd.map ProductViewMsgs fx
    )

processFormMsg : Msg -> App -> (App, Cmd Msg)
processFormMsg formMsg app =
  let (newCreateProductForm, fx) = CPF.update formMsg app.productForm app.appConfig
  in
    ({ app | productForm = newCreateProductForm }, fx)

extractProducts : External (List Product) -> List Product
extractProducts exData =
  case exData of
    Loaded products -> products
    _ -> []
