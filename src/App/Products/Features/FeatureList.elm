module App.Products.Features.FeatureList where

import App.Products.Features.Feature exposing (Feature)
import Data.DirectoryTree            exposing (..)
import Html                          exposing (..)
import Html.Attributes               exposing (..)
import Html.Events                   exposing (onClick)
import String

type alias FeatureList =
  { features: DirectoryTree }

type Action = ShowFeature FileDescription

render : Signal.Address Action -> FeatureList -> Maybe Feature -> Html
render address featureList selectedFeature =
  Html.div
  [ class "directory-tree" ]
  [ Html.ul [] [ drawTree address selectedFeature 2 featureList.features ] ]

drawTree : Signal.Address Action -> Maybe Feature -> Int -> DirectoryTree -> Html
drawTree address selectedLeaf autoOpenDepth tree =
  drawTree' address selectedLeaf autoOpenDepth 0 tree

drawTree' : Signal.Address Action -> Maybe Feature -> Int -> Int -> DirectoryTree -> Html
drawTree' address selectedLeaf autoOpenDepth currentDepth tree =
  case tree of
    DirectoryTree fileDesc [] ->
      Html.li
        []
        [ drawFeatureFile address fileDesc (isEmphasized fileDesc selectedLeaf) ]
    DirectoryTree fileDesc forest ->
      let dirContentsID = directoryContentsID fileDesc.filePath
      in
        Html.li
          []
          [ drawFeatureDirectory address fileDesc dirContentsID
          , Html.ul
            [ id dirContentsID
            , classList [ ("collapse", True), ("in", (currentDepth < autoOpenDepth)) ]
            ]
            (List.map (drawTree' address selectedLeaf autoOpenDepth (currentDepth + 1)) forest)
          ]

directoryContentsID : FilePath -> String
directoryContentsID filePath =
  -- Html element IDs cannot contain slashes
  -- Replace all slashes with the letter 'z'
  let replaceSlashes = \c -> if c == '/' then 'z' else c
  in
    String.map replaceSlashes filePath

isEmphasized : FileDescription -> Maybe Feature -> Bool
isEmphasized fileDesc selectedFeature =
  case selectedFeature of
    Nothing      -> False
    Just feature -> feature.featureID == fileDesc.filePath

drawFeatureFile : Signal.Address Action -> FileDescription -> Bool -> Html
drawFeatureFile address fileDesc isEmphasized =
  Html.div
  [ classList [ ("feature-file", True), ("selected", isEmphasized) ] ]
  [ (drawFeatureFile' address fileDesc) ]

drawFeatureFile' : Signal.Address Action -> FileDescription -> Html
drawFeatureFile' address fileDesc =
  Html.a
  [ href "#", onClick address (ShowFeature fileDesc) ]
  [ Html.span [ classList [("glyphicon", True), ("glyphicon-file", True)] ] []
  , Html.text fileDesc.fileName
  ]

drawFeatureDirectory : Signal.Address Action -> FileDescription -> String -> Html
drawFeatureDirectory address fileDesc directoryContentsID =
  Html.a
  [ href ("#" ++ directoryContentsID)
  , attribute "data-toggle" "collapse"
  , classList [ ("feature-directory", True) ]
  ]
  [ (drawFeatureDirectory' address fileDesc) ]

drawFeatureDirectory' : Signal.Address Action -> FileDescription -> Html
drawFeatureDirectory' address fileDesc =
  Html.div
  []
  [ Html.span [ classList [("glyphicon", True), ("glyphicon-folder-open", True)] ] []
  , Html.text fileDesc.fileName
  ]
