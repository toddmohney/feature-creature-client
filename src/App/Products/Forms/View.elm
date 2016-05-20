module App.Products.Forms.View exposing (..)

import App.Products.Forms.Actions        exposing (..)
import App.Products.Forms.ViewModel      exposing (CreateProductForm)
import Html                              exposing (Html)
import Html.Events                       exposing (onClick)
import UI.App.Primitives.Forms     as UI exposing (..)

view : Signal.Address Action -> CreateProductForm -> Html
view address createProductForm =
  Html.div
    []
    [ UI.input address createProductForm.nameField
    , UI.textarea address createProductForm.repoUrlField
    , UI.submitButton (onClick address SubmitForm)
    ]
