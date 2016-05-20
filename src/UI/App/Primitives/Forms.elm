module UI.App.Primitives.Forms exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events
import String
import UI.Bootstrap.CSS.Buttons as BS

type alias InputField a =
  { defaultValue     : String
  , inputName        : String
  , inputParser      : (String -> a)
  , labelContent     : Html
  , validationErrors : (List String)
  }

requiredStringFieldValidation : String -> (List String)
requiredStringFieldValidation str =
  case String.isEmpty str of
    True  -> [ "This field cannot be blank." ]
    False -> []

input : Signal.Address a -> InputField a -> Html
input address { defaultValue, inputName, inputParser, labelContent, validationErrors } =
  let hasErrors = not <| List.isEmpty validationErrors
      errorMsgs = List.map Html.text validationErrors
      formGroup =
        formGroupContainer
          [ Html.label [ for inputName ] [ labelContent ]
          , Html.input [ class "form-control", id inputName, name inputName, value defaultValue, onInput address inputParser ] []
          , inputErrorIcon hasErrors
          ]
          hasErrors
  in
    Html.div [] [ formGroup, (errorHelpText errorMsgs) ]

textarea : Signal.Address a -> InputField a -> Html
textarea address { defaultValue, inputName, inputParser, labelContent, validationErrors } =
  let hasErrors = not <| List.isEmpty validationErrors
      errorMsgs = List.map Html.text validationErrors
      formGroup =
        formGroupContainer
          [ Html.label [ for inputName ] [ labelContent ]
          , Html.textarea [ class "form-control", id inputName, name inputName, value defaultValue, onInput address inputParser ] []
          , inputErrorIcon hasErrors
          ]
          hasErrors
  in
    Html.div [] [ formGroup, (errorHelpText errorMsgs) ]

cancelButton : Attribute -> Html
cancelButton cancelAction =
  let cancelBtnAttributes = cancelAction :: [ BS.btn ]
  in
    Html.button cancelBtnAttributes [ text "Cancel" ]

submitButton : Attribute -> Html
submitButton submitAction =
  let submitBtnAttributes = submitAction :: [ BS.primaryBtn ]
  in
    Html.button submitBtnAttributes [ text "Submit" ]

onInput : Signal.Address a -> (String -> a) -> Attribute
onInput address contentToValue =
  Html.Events.on
    "input"
    Html.Events.targetValue
    (\str -> Signal.message address (contentToValue str))

inputErrorIcon : Bool -> Html
inputErrorIcon hasErrors =
  let inputErrorClasses = classList
                            [ ("glyphicon", hasErrors)
                            , ("glyphicon-remove", hasErrors)
                            , ("form-control-feedback", hasErrors)
                            ]
  in
    Html.span [ inputErrorClasses ] []

errorHelpText : List Html -> Html
errorHelpText errorMsgs =
  Html.span
    [ classList [("help-block", True)] ]
    errorMsgs

formGroupContainer : List Html -> Bool -> Html
formGroupContainer content hasErrors =
  let formGroupClasses = classList
                           [ ("form-group", True)
                           , ("has-error", hasErrors)
                           , ("has-feedback", hasErrors)
                           ]
  in
    Html.div [ formGroupClasses ] content
