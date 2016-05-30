module App.Products.Forms.View exposing ( view )

import App.Messages             exposing (Msg(..))
import App.Products.Forms.ViewModel      exposing (CreateProductForm)
import Html                              exposing (Html)
import Html.Events                       exposing (onClick)
import UI.App.Primitives.Forms     as UI exposing (..)

view : CreateProductForm -> Html Msg
view createProductForm =
  Html.div
    []
    [ UI.input createProductForm.nameField
    , UI.textarea createProductForm.repoUrlField
    , UI.submitButton (onClick SubmitForm)
    ]
