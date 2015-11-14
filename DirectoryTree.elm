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
view tree = ul [] [ drawTree tree ]

drawTree : DirectoryTree -> Html
drawTree tree =
  case tree of
    DirectoryTree fileDesc [] ->
      li [] [ text fileDesc.fileName ]
    DirectoryTree fileDesc forest ->
      li
        []
        [
          text fileDesc.fileName,
          ul [] (map drawTree forest)
        ]
