module Data.DirectoryTree exposing
  ( DirectoryTree (..)
  , FileDescription
  , FilePath
  , createNode
  , rootNode
  , parseFeatureTree
  )

import Json.Decode as Json exposing ((:=))

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

parseFeatureTree : Json.Decoder DirectoryTree
parseFeatureTree =
  Json.object2 DirectoryTree
  ("fileDescription" := parseFileDescription)
  ("forest"          := Json.list (lazy (\_ -> parseFeatureTree)))

parseFileDescription : Json.Decoder FileDescription
parseFileDescription =
  Json.object2 FileDescription
    ("fileName" := Json.string)
    ("filePath" := Json.string)

lazy : (() -> Json.Decoder a) -> Json.Decoder a
lazy thunk =
  Json.customDecoder Json.value
  (\js -> Json.decodeValue (thunk ()) js)
