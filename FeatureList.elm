module FeatureList where

import DirectoryTree as DT
import Effects exposing (Effects)
import Http as Http        exposing (..)
import Html as Html        exposing (..)
import Json.Decode as Json exposing ((:=))
import Task as Task        exposing (..)


-- MODEL

type alias FeatureList =
  { features: DT.DirectoryTree
  , url: String
  }

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
   Http.get jsonToFeatureTree url
    |> Task.toResult
    |> Task.map UpdateFeatures
    |> Effects.task

jsonToFeatureTree : Json.Decoder DT.DirectoryTree
jsonToFeatureTree =
  Json.object2 DT.DirectoryTree
  ("fileDescription" := parseFileDescription)
  ("forest"          := Json.list (lazy (\_ -> jsonToFeatureTree)))

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

type Action = RequestFeatures
            | UpdateFeatures (Result Error DT.DirectoryTree)

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
view address featureList = Html.div [] [ DT.view featureList.features ]
