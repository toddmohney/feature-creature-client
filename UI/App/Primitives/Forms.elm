module UI.App.Primitives.Forms where

import Html exposing (..)
import Html.Attributes exposing (..)
import UI.Bootstrap.CSS.Buttons as BS

input : String -> Html -> Html
input inputName labelContent =
  Html.div
    [ class "form-group" ]
    [
      Html.label
        [ for inputName ]
        [ labelContent ]
    , Html.input
        [ class "form-control"
        , id inputName
        , name inputName
        ]
        []
    ]

textarea : String -> Html -> Html
textarea inputName labelContent =
  Html.div
    [ class "form-group" ]
    [
      Html.label
        [ for inputName ]
        [ labelContent ]
    , Html.textarea
        [ class "form-control"
        , id inputName
        , name inputName
        ]
        []
    ]

cancelButton : Attribute -> Html
cancelButton cancelAction =
  let cancelBtnAttributes = cancelAction :: [ BS.btn ]
  in Html.button
       cancelBtnAttributes
       [ text "Cancel" ]

submitButton : Attribute -> Html
submitButton submitAction =
  let submitBtnAttributes = submitAction :: [ BS.primaryBtn ]
  in Html.button
       submitBtnAttributes
       [ text "Submit" ]


