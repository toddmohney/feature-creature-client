module DirectoryTree where

import Html exposing (..)
import List exposing (map)

-- MODEL

type alias FilePath = String
type DirectoryTree =
  DirectoryTree FilePath (List DirectoryTree)

createNode : String -> (List DirectoryTree) -> DirectoryTree
createNode label forest = DirectoryTree label forest

-- VIEW

view : DirectoryTree -> Html
view (DirectoryTree label forest) =
  ul
    []
    [
      drawNode label
    , li [] (map drawTree forest)
    ]

drawNode : FilePath -> Html
drawNode path = li [] [ text path ]

drawTree : DirectoryTree -> Html
drawTree tree =
  case tree of
    DirectoryTree label [] ->
      drawNode label
    DirectoryTree label forest ->
      ul
        []
        [
          drawNode label
        , li [] (map drawTree forest)
        ]
