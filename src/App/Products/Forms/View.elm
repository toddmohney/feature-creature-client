module App.Products.Forms.View exposing (..)

import App.Products.Forms.Actions        exposing (..)
import App.Products.Forms.ViewModel      exposing (CreateProductForm)
import Html                              exposing (Html)
import Html.Events                       exposing (onClick)
import UI.App.Primitives.Forms     as UI exposing (..)

view : CreateProductForm -> Html Action
view createProductForm =
  Html.div
    []
    [ UI.input createProductForm.nameField
    , UI.textarea createProductForm.repoUrlField
    , UI.submitButton (onClick SubmitForm)
    ]
