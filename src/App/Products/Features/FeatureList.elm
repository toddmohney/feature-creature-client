module App.Products.Features.FeatureList exposing
  ( FeatureList
  , render
  )

import App.Products.Features.Feature  exposing (Feature)
import App.Products.Features.Messages exposing (Msg(..))
import Data.DirectoryTree             exposing (..)
import Html                           exposing (..)
import Html.Attributes as Html        exposing (..)
import Html.Events                    exposing (onClick)
import String
import UI.Bootstrap.Components.Glyphicons as Glyph

type alias FeatureList =
  { features: DirectoryTree }

type alias DirectoryTreeRenderOptions =
  { selectedFeature    : Maybe Feature
  , autoOpenDepth      : Int
  , currentRenderDepth : Int
  }

type FileType = File FileDescription
              | Directory FileDescription (List DirectoryTree)

render : FeatureList -> Maybe Feature -> Html Msg
render featureList selectedFeature =
  Html.div
  [ class "directory-tree" ]
  [ Html.ul [] [ drawTree (treeRenderOpts selectedFeature 2) featureList.features ] ]

drawTree : DirectoryTreeRenderOptions -> DirectoryTree -> Html Msg
drawTree renderOpts tree =
  case fileType tree of
    File fileDesc ->
      drawFile renderOpts.selectedFeature fileDesc
    Directory fileDesc directoryContents ->
      drawDirectory renderOpts fileDesc directoryContents

drawFile : Maybe Feature -> FileDescription -> Html Msg
drawFile selectedFeature fileDesc =
  fileListItem
    <| drawFeatureFile fileDesc
    <| isEmphasized fileDesc selectedFeature

drawDirectory : DirectoryTreeRenderOptions -> FileDescription -> List DirectoryTree -> Html Msg
drawDirectory renderOpts directory directoryContents =
  let dirContentsID = directoryContentsID directory.filePath
  in
    directoryListItem
      (drawFeatureDirectory directory dirContentsID)
      (directoryList dirContentsID renderOpts directoryContents)

fileListItem : Html a -> Html a
fileListItem content = Html.li [] [ content ]

directoryList : String -> DirectoryTreeRenderOptions -> List DirectoryTree -> Html Msg
directoryList dirContentsID renderOpts directoryContents =
  let elemID = Html.id dirContentsID
      nextRenderOpts = { renderOpts | currentRenderDepth = renderOpts.currentRenderDepth + 1 }
      classes = Html.classList [ ("collapse", True)
                               , ("in", (renderOpts.currentRenderDepth < renderOpts.autoOpenDepth))
                               ]
  in
    Html.ul
    [ elemID , classes ]
    (List.map (drawTree nextRenderOpts) directoryContents)

directoryListItem : Html a -> Html a -> Html a
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

drawFeatureFile : FileDescription -> Bool -> Html Msg
drawFeatureFile fileDesc isEmphasized =
  Html.div
  [ classList [ ("feature-file", True), ("selected", isEmphasized) ] ]
  [ (drawFeatureFile' fileDesc) ]

drawFeatureFile' : FileDescription -> Html Msg
drawFeatureFile' fileDesc =
  Html.a
  [ href "#", onClick (ShowFeature fileDesc) ]
  [ Glyph.fileIcon
  , Html.text fileDesc.fileName
  ]

drawFeatureDirectory : FileDescription -> String -> Html Msg
drawFeatureDirectory fileDesc directoryContentsID =
  Html.a
  [ href ("#" ++ directoryContentsID)
  , attribute "data-toggle" "collapse"
  , classList [ ("feature-directory", True) ]
  ]
  [ (drawFeatureDirectory' fileDesc) ]

drawFeatureDirectory' : FileDescription -> Html Msg
drawFeatureDirectory' fileDesc =
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
