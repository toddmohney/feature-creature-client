module Products.Forms.View where

import Html                     exposing (Html)
import Html.Events              exposing (onClick)
import Products.Forms.Actions   exposing (..)
import Products.Forms.ViewModel exposing (CreateProductForm)
import UI.App.Primitives.Forms     as UI exposing (..)

view : Signal.Address Action -> CreateProductForm -> Html
view address createProductForm =
  Html.div
    []
    [ UI.input address createProductForm.nameField
    , UI.textarea address createProductForm.repoUrlField
    , UI.submitButton (onClick address SubmitForm)
    ]
