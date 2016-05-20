module App.Products.Features.FeatureList exposing
  ( FeatureList
  , Action(..)
  , render
  )

import App.Products.Features.Feature exposing (Feature)
import Data.DirectoryTree            exposing (..)
import Html                          exposing (..)
import Html.Attributes as Html       exposing (..)
import Html.Events                   exposing (onClick)
import String
import UI.Bootstrap.Components.Glyphicons as Glyph

type alias FeatureList =
  { features: DirectoryTree }

type alias DirectoryTreeRenderOptions =
  { selectedFeature    : Maybe Feature
  , autoOpenDepth      : Int
  , currentRenderDepth : Int
  }

type Action = ShowFeature FileDescription

type FileType = File FileDescription
              | Directory FileDescription (List DirectoryTree)

render : Signal.Address Action -> FeatureList -> Maybe Feature -> Html
render address featureList selectedFeature =
  Html.div
  [ class "directory-tree" ]
  [ Html.ul [] [ drawTree address (treeRenderOpts selectedFeature 2) featureList.features ] ]

drawTree : Signal.Address Action -> DirectoryTreeRenderOptions -> DirectoryTree -> Html
drawTree address renderOpts tree =
  case fileType tree of
    File fileDesc ->
      drawFile address renderOpts.selectedFeature fileDesc
    Directory fileDesc directoryContents ->
      drawDirectory address renderOpts fileDesc directoryContents

drawFile : Signal.Address Action -> Maybe Feature -> FileDescription -> Html
drawFile address selectedFeature fileDesc =
  fileListItem
    <| drawFeatureFile address fileDesc
    <| isEmphasized fileDesc selectedFeature

drawDirectory : Signal.Address Action -> DirectoryTreeRenderOptions -> FileDescription -> List DirectoryTree -> Html
drawDirectory address renderOpts directory directoryContents =
  let dirContentsID = directoryContentsID directory.filePath
  in
    directoryListItem
      (drawFeatureDirectory address directory dirContentsID)
      (directoryList address dirContentsID renderOpts directoryContents)

fileListItem : Html -> Html
fileListItem content = Html.li [] [ content ]

directoryList : Signal.Address Action -> String -> DirectoryTreeRenderOptions -> List DirectoryTree -> Html
directoryList address dirContentsID renderOpts directoryContents =
  let elemID = Html.id dirContentsID
      nextRenderOpts = { renderOpts | currentRenderDepth = renderOpts.currentRenderDepth + 1 }
      classes = Html.classList [ ("collapse", True)
                               , ("in", (renderOpts.currentRenderDepth < renderOpts.autoOpenDepth))
                               ]
  in
    Html.ul
    [ elemID , classes ]
    (List.map (drawTree address nextRenderOpts) directoryContents)

directoryListItem : Html -> Html -> Html
directoryListItem directoryHTML directoryContentsHTML =
  Html.li
  []
  [ directoryHTML, directoryContentsHTML ]

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
  [ Glyph.fileIcon
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
  [ Glyph.folderOpenIcon
  , Html.text fileDesc.fileName
  ]

fileType : DirectoryTree -> FileType
fileType tree =
  case tree of
    DirectoryTree fileDesc []     -> File fileDesc
    DirectoryTree fileDesc forest -> Directory fileDesc forest

treeRenderOpts : Maybe Feature -> Int -> DirectoryTreeRenderOptions
treeRenderOpts selectedFeature autoOpenDepth =
  { selectedFeature    = selectedFeature
  , autoOpenDepth      = autoOpenDepth
  , currentRenderDepth = 0
  }
