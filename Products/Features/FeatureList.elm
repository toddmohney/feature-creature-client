module Products.Features.FeatureList where

import Data.DirectoryTree exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Products.Features.Feature exposing (..)

type alias FeatureList =
  { features: DirectoryTree }

type Action = ShowFeature FileDescription

render : Signal.Address Action
      -> FeatureList
      -> Html
render address featureList =
  Html.ul [] [ drawTree address featureList.features ]

drawTree : Signal.Address Action
        -> DirectoryTree
        -> Html
drawTree address tree =
  case tree of
    DirectoryTree fileDesc [] ->
      Html.li
        []
        [ drawFeatureFile address fileDesc ]
    DirectoryTree fileDesc forest ->
      Html.li
        []
        [ drawFeatureDirectory address fileDesc
        , Html.ul [] (List.map (drawTree address) forest)
        ]

drawFeatureFile : Signal.Address Action
               -> FileDescription
               -> Html
drawFeatureFile address fileDesc =
  a [ href "#", onClick address (ShowFeature fileDesc) ] [ text fileDesc.fileName ]

drawFeatureDirectory : Signal.Address Action
                    -> FileDescription
                    -> Html
drawFeatureDirectory address fileDesc =
  div [] [ text fileDesc.fileName ]
