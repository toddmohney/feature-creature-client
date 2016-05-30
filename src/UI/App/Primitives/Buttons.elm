module UI.App.Primitives.Buttons exposing ( primaryBtn , secondaryBtn )

import Html exposing (Html, Attribute)
import UI.Bootstrap.CSS.Buttons as BS

primaryBtn : List (Attribute a) -> String -> Html a
primaryBtn attrs buttonText =
  let buttonAttrs = attrs ++ [ BS.primaryBtn ]
  in Html.button buttonAttrs [ Html.text buttonText ]

secondaryBtn : List (Attribute a) -> String -> Html a
secondaryBtn attrs buttonText =
  let buttonAttrs = attrs ++ [ BS.secondaryBtn ]
  in Html.button buttonAttrs [ Html.text buttonText ]
