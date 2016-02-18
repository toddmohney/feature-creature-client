module UI.App.Components.Containers where

import Html                    exposing (Html)
import Html.Attributes as Html

type alias CssClassList = List (String, Bool)

clearfix : CssClassList -> List Html -> Html
clearfix extraClasses contents =
  let defaultCssClasses = [ ("clearfix", True) ]
      cssClasses = defaultCssClasses ++ extraClasses
  in
    Html.div [ Html.classList cssClasses ] contents
