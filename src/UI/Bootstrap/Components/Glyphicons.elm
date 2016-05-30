module UI.Bootstrap.Components.Glyphicons exposing
  ( fileIcon
  , folderOpenIcon
  , searchIcon
  , editIcon
  , removeIcon
  )

import Html exposing (Attribute, Html)
import Html.Attributes as Html

editIcon : Html a
editIcon = glyphSpan "pencil" []

removeIcon : Html a
removeIcon = glyphSpan "remove" [ ("text-danger", True) ]

fileIcon : Html a
fileIcon = glyphSpan "file" []

folderOpenIcon : Html a
folderOpenIcon = glyphSpan "folder-open" []

searchIcon : Html a
searchIcon = glyphSpan "search" []

glyphSpan : String -> List (String, Bool) -> Html a
glyphSpan name extraAttrs =
  Html.span
  [ glyphClasses name extraAttrs ]
  []

glyphClasses : String -> List (String, Bool) -> Attribute a
glyphClasses name extraAttrs =
  let glyphClasses = [ ("glyphicon", True)
                     , ("glyphicon-" ++ name, True)
                     ]
  in
    Html.classList <| glyphClasses ++ extraAttrs
