module App.App exposing
  ( App
  , init
  , view
  )

import App.Messages                               exposing (Msg(..))
import App.AppConfig                              exposing (..)
import App.Products.Product         as P          exposing (Product)
import App.Products.Forms.ViewModel as CPF        exposing (CreateProductForm)
import App.Products.Forms.View      as CPF
import App.Products.Navigation      as Navigation
import App.Products.Requests        as P
import App.Products.Show.ViewModel  as PV         exposing (ProductView)
import App.Products.Show.View       as PV
import Data.External                              exposing (External(..))
import Html                                       exposing (Html)
import Html.App as Html
import Html.Attributes as Html
import Debug exposing (log)

type alias App =
  { appConfig   : Maybe AppConfig
  , products    : External (List Product)
  , currentView : Navigation.CurrentView
  , productForm : CreateProductForm
  , productView : Maybe ProductView
  }

init : AppConfig -> (App, Cmd Msg)
init appConfig =
  let initialState = { appConfig   = Just appConfig
                     , products    = NotLoaded
                     , currentView = Navigation.LoadingView
                     , productForm = CPF.init P.newProduct
                     , productView = Nothing
                     }
  in
    initialState ! [P.getProducts appConfig]

view : App -> Html Msg
view app =
  case log "currentView: " app.currentView of
    Navigation.LoadingView           -> renderLoadingView
    Navigation.ErrorView err         -> renderErrorView err
    Navigation.CreateProductFormView -> renderProductsForm app
    Navigation.ProductView           -> renderProductView app
    Navigation.DomainTermsView       -> renderProductView app
    Navigation.UserRolesView         -> renderProductView app

renderLoadingView : Html Msg
renderLoadingView = Html.div [] [ Html.text "loading..." ]

renderErrorView : String -> Html Msg
renderErrorView err = Html.div [] [ Html.text err ]

renderProductsForm : App -> Html Msg
renderProductsForm app = mainContent [ CPF.view app.productForm ]

renderProductView : App -> Html Msg
renderProductView app =
  case app.productView of
    Nothing -> Html.div [] [ Html.text "No products found" ]
    Just pv -> mainContent  [ Html.map ProductViewActions (PV.view pv) ]

mainContent : List (Html Msg) -> Html Msg
mainContent content =
  Html.div
    [ Html.id "main_content"
    , Html.classList [ ("container-fluid", True) ]
    ]
    content
