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
  , labelContent     : Html a
  , validationErrors : (List String)
  }

requiredStringFieldValidation : String -> (List String)
requiredStringFieldValidation str =
  case String.isEmpty str of
    True  -> [ "This field cannot be blank." ]
    False -> []

input : InputField a -> Html a
input { defaultValue, inputName, inputParser, labelContent, validationErrors } =
  let hasErrors = not <| List.isEmpty validationErrors
      errorMsgs = List.map Html.text validationErrors
      formGroup =
        formGroupContainer
          [ Html.label [ for inputName ] [ labelContent ]
          , Html.input [ class "form-control", id inputName, name inputName, value defaultValue, onInput inputParser ] []
          , inputErrorIcon hasErrors
          ]
          hasErrors
  in
    Html.div [] [ formGroup, (errorHelpText errorMsgs) ]

textarea : InputField a -> Html a
textarea { defaultValue, inputName, inputParser, labelContent, validationErrors } =
  let hasErrors = not <| List.isEmpty validationErrors
      errorMsgs = List.map Html.text validationErrors
      formGroup =
        formGroupContainer
          [ Html.label [ for inputName ] [ labelContent ]
          , Html.textarea [ class "form-control", id inputName, name inputName, value defaultValue, onInput inputParser ] []
          , inputErrorIcon hasErrors
          ]
          hasErrors
  in
    Html.div [] [ formGroup, (errorHelpText errorMsgs) ]

cancelButton : Attribute a -> Html a
cancelButton cancelAction =
  let cancelBtnAttributes = cancelAction :: [ BS.btn ]
  in
    Html.button cancelBtnAttributes [ text "Cancel" ]

submitButton : Attribute a -> Html a
submitButton submitAction =
  let submitBtnAttributes = submitAction :: [ BS.primaryBtn ]
  in
    Html.button submitBtnAttributes [ text "Submit" ]

onInput : (String -> a) -> Attribute a
onInput contentToValue =
  Html.Events.onInput contentToValue

inputErrorIcon : Bool -> Html a
inputErrorIcon hasErrors =
  let inputErrorClasses = classList
                            [ ("glyphicon", hasErrors)
                            , ("glyphicon-remove", hasErrors)
                            , ("form-control-feedback", hasErrors)
                            ]
  in
    Html.span [ inputErrorClasses ] []

errorHelpText : List (Html a) -> Html a
errorHelpText errorMsgs =
  Html.span
    [ classList [("help-block", True)] ]
    errorMsgs

formGroupContainer : List (Html a) -> Bool -> Html a
formGroupContainer content hasErrors =
  let formGroupClasses = classList
                           [ ("form-group", True)
                           , ("has-error", hasErrors)
                           , ("has-feedback", hasErrors)
                           ]
  in
    Html.div [ formGroupClasses ] content
