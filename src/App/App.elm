module App.App where

import App.Actions                                exposing (..)
import App.AppConfig                              exposing (..)
import App.Products.Product         as P          exposing (Product)
import App.Products.Forms.ViewModel as CPF        exposing (CreateProductForm)
import App.Products.Forms.View      as CPF
import App.Products.Navigation      as Navigation
import App.Products.Show.ViewModel  as PV         exposing (ProductView)
import App.Products.Show.View       as PV
import Data.External                              exposing (External(..))
import Effects                                    exposing (Effects)
import Html                                       exposing (Html)
import Html.Attributes as Html

type alias App =
  { appConfig   : Maybe AppConfig
  , products    : External (List Product)
  , currentView : Navigation.CurrentView
  , productForm : CreateProductForm
  , productView : Maybe ProductView
  }

init : (App, Effects Action)
init =
  let initialState = { appConfig   = Nothing
                     , products    = NotLoaded
                     , currentView = Navigation.LoadingView
                     , productForm = CPF.init P.newProduct
                     , productView = Nothing
                     }
  in
    (initialState, Effects.none)

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
      productFormHtml   = CPF.view forwardedAddress app.productForm
  in
    mainContent [ productFormHtml ]

renderProductView : Signal.Address Action -> App -> Html
renderProductView address app =
  case app.productView of
    Nothing -> Html.div [] [ Html.text "No products found" ]
    Just pv ->
      let forwardedAddress = (Signal.forwardTo address ProductViewActions)
          productViewHtml  = PV.view forwardedAddress pv
      in
        mainContent  [ productViewHtml ]

mainContent : List Html -> Html
mainContent content =
  Html.div
    [ Html.id "main_content"
    , Html.classList [ ("container-fluid", True) ]
    ]
    content
