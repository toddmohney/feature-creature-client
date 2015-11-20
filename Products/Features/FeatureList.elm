module Products.Features.FeatureList where

import Data.DirectoryTree as DT
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Products.Features.Feature exposing (..)

-- MODEL

type alias FeatureList =
  { features: DT.DirectoryTree }

type Action = ShowFeature DT.FileDescription

render : Signal.Address Action -> FeatureList -> Html
render address featureList =
  Html.div
  [ class "pull-left" ]
  [ drawFeatureFiles address featureList.features ]

drawFeatureFiles : Signal.Address Action -> DT.DirectoryTree -> Html
drawFeatureFiles address tree =
  Html.ul [] [ drawTree address tree ]

drawTree : Signal.Address Action -> DT.DirectoryTree -> Html
drawTree address tree =
  case tree of
    DT.DirectoryTree fileDesc [] ->
      Html.li [] [ drawFeatureFile address fileDesc ]
    DT.DirectoryTree fileDesc forest ->
      Html.li
        []
        [
          drawFeatureDirectory address fileDesc,
          Html.ul [] (List.map (drawTree address) forest)
        ]

drawFeatureFile : Signal.Address Action -> DT.FileDescription -> Html
drawFeatureFile address fileDesc =
  a [ href "#", onClick address (ShowFeature fileDesc) ] [ text fileDesc.fileName ]

drawFeatureDirectory : Signal.Address Action -> DT.FileDescription -> Html
drawFeatureDirectory address fileDesc =
  div [] [ text fileDesc.fileName ]
