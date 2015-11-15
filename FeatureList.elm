module FeatureList where

import DirectoryTree as DT
import Effects                 exposing (Effects)
import Http as Http            exposing (..)
import Html as Html            exposing (..)
import Html.Attributes as Html exposing (..)
import Html.Events             exposing (onClick)
import Json.Decode as Json     exposing ((:=))
import Task as Task            exposing (..)


-- MODEL

type alias FeatureList =
  { features: DT.DirectoryTree
  , url: String
  }

type Action = RequestFeatures
            | UpdateFeatures (Result Error DT.DirectoryTree)
            | ShowFeature DT.FileDescription

init : Int -> (FeatureList, Effects Action)
init id =
  let url = featuresUrl id
  in ( { features = DT.rootNode, url = url }
     , getFeaturesList url
     )

featuresUrl : Int -> String
featuresUrl id = "http://localhost:8081/products/" ++ (toString id) ++ "/features"

getFeaturesList : String -> Effects Action
getFeaturesList url =
   Http.get parseFeatureTree url
    |> Task.toResult
    |> Task.map UpdateFeatures
    |> Effects.task

parseFeatureTree : Json.Decoder DT.DirectoryTree
parseFeatureTree =
  Json.object2 DT.DirectoryTree
  ("fileDescription" := parseFileDescription)
  ("forest"          := Json.list (lazy (\_ -> parseFeatureTree)))

parseFileDescription : Json.Decoder DT.FileDescription
parseFileDescription =
  Json.object2 DT.FileDescription
  ("fileName" := Json.string)
  ("filePath" := Json.string)

lazy : (() -> Json.Decoder a) -> Json.Decoder a
lazy thunk =
  Json.customDecoder Json.value
  (\js -> Json.decodeValue (thunk ()) js)

-- UPDATE

update : Action -> FeatureList -> (FeatureList, Effects Action)
update action featureList =
  case action of
    RequestFeatures ->
      (featureList, getFeaturesList featureList.url)
    UpdateFeatures resultFeatureTree ->
      case resultFeatureTree of
        Ok featureTree ->
          ( { featureList | features <- featureTree }
          , Effects.none
          )
        Err string ->
          let errorFileDescription = DT.createNode { fileName = "/I-errored", filePath = "/I-errored" } []
              errorModel = { features = errorFileDescription, url = featureList.url }
            in (errorModel, Effects.none)

-- VIEW

view : Signal.Address Action -> FeatureList -> Html
view address featureList = Html.div [] [ drawFeatureFiles address featureList.features ]

drawFeatureFiles : Signal.Address Action -> DT.DirectoryTree -> Html
drawFeatureFiles address tree = ul [] [ drawTree address tree ]

drawTree : Signal.Address Action -> DT.DirectoryTree -> Html
drawTree address tree =
  case tree of
    DT.DirectoryTree fileDesc [] ->
      li [] [ drawFeatureFile address fileDesc ]
    DT.DirectoryTree fileDesc forest ->
      li
        []
        [
          drawFeatureDirectory address fileDesc,
          ul [] (List.map (drawTree address) forest)
        ]

drawFeatureFile : Signal.Address Action -> DT.FileDescription -> Html
drawFeatureFile address fileDesc =
  a [ href "#", onClick address (ShowFeature fileDesc) ] [ text fileDesc.fileName ]

drawFeatureDirectory : Signal.Address Action -> DT.FileDescription -> Html
drawFeatureDirectory address fileDesc =
  div [] [ text fileDesc.fileName ]
