module UI.App.Components.Containers exposing (..)

import Html exposing (Html)
import Html.Attributes as Html

type alias CssClassList = List (String, Bool)

clearfix : CssClassList -> List (Html a) -> Html a
clearfix extraClasses contents =
  let defaultCssClasses = [ ("clearfix", True) ]
      cssClasses = defaultCssClasses ++ extraClasses
  in
    Html.div [ Html.classList cssClasses ] contents
