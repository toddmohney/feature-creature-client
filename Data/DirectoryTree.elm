module Data.DirectoryTree where

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
