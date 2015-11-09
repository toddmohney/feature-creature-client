module DirectoryTree where

import Html exposing (..)
import List exposing (map)

-- MODEL

type alias FilePath = String

type DirectoryTree =
  DirectoryTree FileDescription (List DirectoryTree)

type alias FileDescription = { fileName : String
                             , filePath : FilePath
                             }

createNode : FileDescription -> (List DirectoryTree) -> DirectoryTree
createNode fileDesc forest = DirectoryTree fileDesc forest

rootNode : DirectoryTree
rootNode = createNode { fileName = "/", filePath = "/" } []

-- VIEW

view : DirectoryTree -> Html
view (DirectoryTree fileDesc forest) =
  ul
    []
    [
      drawNode fileDesc
    , li [] (map drawTree forest)
    ]

drawNode : FileDescription -> Html
drawNode fileDesc = li [] [ text fileDesc.fileName ]

drawTree : DirectoryTree -> Html
drawTree tree =
  case tree of
    DirectoryTree fileDesc [] ->
      drawNode fileDesc
    DirectoryTree fileDesc forest ->
      ul
        []
        [
          drawNode fileDesc
        , li [] (map drawTree forest)
        ]
