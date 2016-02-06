module UI.App.Primitives.Buttons
  ( primaryBtn
  , secondaryBtn
  ) where

import Html exposing (Html, Attribute)
import UI.Bootstrap.CSS.Buttons as BS

primaryBtn : List Attribute -> String -> Html
primaryBtn attrs buttonText =
  let buttonAttrs = attrs ++ [ BS.primaryBtn ]
  in Html.button buttonAttrs [ Html.text buttonText ]

secondaryBtn : List Attribute -> String -> Html
secondaryBtn attrs buttonText =
  let buttonAttrs = attrs ++ [ BS.secondaryBtn ]
  in Html.button buttonAttrs [ Html.text buttonText ]
