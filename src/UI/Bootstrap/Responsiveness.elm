module UI.Bootstrap.Responsiveness exposing
  ( ScreenSize(..)
  , colResetBlock
  )

import Html exposing (Html)
import Html.Attributes as Html

type ScreenSize = Large
                | Medium
                | Small
                | XSmall

colResetBlock : ScreenSize -> Html
colResetBlock size =
  let blockClass =
    case size of
      Large  -> "visible-lg-block"
      Medium -> "visible-md-block"
      Small  -> "visible-sm-block"
      XSmall -> "visible-xs-block"
  in
    Html.div
    [ Html.classList [("clearfix", True), (blockClass, True)] ]
    []
