module UI.Bootstrap.Components.Glyphicons
  ( fileIcon
  , folderOpenIcon
  , searchIcon
  ) where

import Html                    exposing (Attribute, Html)
import Html.Attributes as Html

fileIcon : Html
fileIcon = glyphSpan "file"

folderOpenIcon : Html
folderOpenIcon = glyphSpan "folder-open"

searchIcon : Html
searchIcon = glyphSpan "search"

glyphSpan : String -> Html
glyphSpan name =
  Html.span
  [ glyphClasses name ]
  []

glyphClasses : String -> Attribute
glyphClasses name =
  Html.classList
    [ ("glyphicon", True)
    , ("glyphicon-" ++ name, True)
    ]
