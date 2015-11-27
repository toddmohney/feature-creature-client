module UI.App.Primitives.Forms where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events
import UI.Bootstrap.CSS.Buttons as BS

input : Signal.Address a -> String -> Html -> (String -> a) -> Html
input address inputName labelContent inputParser =
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
        , onInput address inputParser
        ]
        []
    ]

textarea : Signal.Address a -> String -> Html -> (String -> a) -> Html
textarea address inputName labelContent inputParser =
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
        , onInput address inputParser
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

onInput : Signal.Address a -> (String -> a) -> Attribute
onInput address contentToValue =
  Html.Events.on
    "input"
    Html.Events.targetValue
    (\str -> Signal.message address (contentToValue str))