module UI.Bootstrap.Components.Glyphicons
  ( fileIcon
  , folderOpenIcon
  , searchIcon
  , editIcon
  , removeIcon
  ) where

import Html                    exposing (Attribute, Html)
import Html.Attributes as Html

editIcon : Html
editIcon = glyphSpan "pencil" []

removeIcon : Html
removeIcon = glyphSpan "remove" [ ("text-danger", True) ]

fileIcon : Html
fileIcon = glyphSpan "file" []

folderOpenIcon : Html
folderOpenIcon = glyphSpan "folder-open" []

searchIcon : Html
searchIcon = glyphSpan "search" []

glyphSpan : String -> List (String, Bool) -> Html
glyphSpan name extraAttrs =
  Html.span
  [ glyphClasses name extraAttrs ]
  []

glyphClasses : String -> List (String, Bool) -> Attribute
glyphClasses name extraAttrs =
  let glyphClasses = [ ("glyphicon", True)
                     , ("glyphicon-" ++ name, True)
                     ]
  in
    Html.classList <| glyphClasses ++ extraAttrs
