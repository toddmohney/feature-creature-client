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

render : Signal.Address Action
      -> FeatureList
      -> Maybe Feature
      -> Html
render address featureList selectedFeature =
  Html.div
  [ class "directory-tree" ]
  [ Html.ul [] [ drawTree address selectedFeature featureList.features ] ]

drawTree : Signal.Address Action -> Maybe Feature -> DirectoryTree -> Html
drawTree address selectedLeaf tree =
  case tree of
    DirectoryTree fileDesc [] ->
      Html.li
        []
        [ drawFeatureFile address fileDesc (isEmphasized fileDesc selectedLeaf) ]
    DirectoryTree fileDesc forest ->
      let replaceSlashes = \c -> if c == '/' then 'a' else c
          directoryContentsID = String.map replaceSlashes fileDesc.filePath
      in
        Html.li
          []
          [ drawFeatureDirectory address fileDesc directoryContentsID
          , Html.ul
            [ id directoryContentsID
            , classList [ ("collapse", True) ]
            ]
            (List.map (drawTree address selectedLeaf) forest)
          ]

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
