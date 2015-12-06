module UI.App.Primitives.Forms where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events
import String
import UI.Bootstrap.CSS.Buttons as BS

type alias InputField a =
  { inputName        : String
  , labelContent     : Html
  , inputParser      : (String -> a)
  , validationErrors : (List String)
  }

requiredStringFieldValidation : String -> (List String)
requiredStringFieldValidation str =
  case String.isEmpty str of
    True  -> [ "This field cannot be blank." ]
    False -> []

input : Signal.Address a -> InputField a -> Html
input address { inputName, labelContent, inputParser, validationErrors } =
  let hasErrors = not <| List.isEmpty validationErrors
      errorMsgs = List.map Html.text validationErrors
      errorHelpText =
        Html.span
          [ classList [("help-block", True)] ]
          errorMsgs
      formGroup =
        Html.div
          [ classList
              [ ("form-group", True)
              , ("has-error", hasErrors)
              , ("has-feedback", hasErrors)
              ]
          ]
          [ Html.label
              [ for inputName ]
              [ labelContent ]
          , Html.input
              [ class "form-control"
              , id inputName
              , name inputName
              , onInput address inputParser
              ]
              []
          , Html.span
              [ classList
                  [ ("glyphicon", hasErrors)
                  , ("glyphicon-remove", hasErrors)
                  , ("form-control-feedback", hasErrors)
                  ]
              ]
              []
          ]
  in
     Html.div [] [ formGroup, errorHelpText ]

textarea : Signal.Address a -> InputField a -> Html
textarea address { inputName, labelContent, inputParser, validationErrors } =
  let hasErrors = not <| List.isEmpty validationErrors
      errorMsgs = List.map Html.text validationErrors
      errorHelpText =
        Html.span
          [ classList [("help-block", True)] ]
          errorMsgs
      formGroup =
        Html.div
          [ classList
              [ ("form-group", True)
              , ("has-error", hasErrors)
              , ("has-feedback", hasErrors)
              ]
          ]
          [ Html.label
              [ for inputName ]
              [ labelContent ]
          , Html.textarea
              [ class "form-control"
              , id inputName
              , name inputName
              , onInput address inputParser
              ]
              []
          , Html.span
              [ classList
                  [ ("glyphicon", hasErrors)
                  , ("glyphicon-remove", hasErrors)
                  , ("form-control-feedback", hasErrors)
                  ]
              ]
              []
          ]
  in
     Html.div [] [ formGroup, errorHelpText ]

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
