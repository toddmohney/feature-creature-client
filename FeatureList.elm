module FeatureList where

import DirectoryTree as DT
import Effects exposing (Effects)
import Http as Http        exposing (..)
import Html as Html        exposing (..)
import Json.Decode as Json exposing ((:=))
import Task as Task        exposing (..)


-- MODEL

type alias Model =
  { features: DT.DirectoryTree
  , url: String
  }

init : String -> (Model, Effects Action)
init url =
  ( { features = (DT.createNode "/" []), url = url }
  , getFeaturesList url
  )

getFeaturesList : String -> Effects Action
getFeaturesList url =
   Http.get jsonToFeatureTree url
    |> Task.toResult
    |> Task.map UpdateFeatures
    |> Effects.task

jsonToFeatureTree : Json.Decoder DT.DirectoryTree
jsonToFeatureTree =
  Json.object2 DT.DirectoryTree
  ("label" := Json.string)
  ("forest" := Json.list (lazy (\_ -> jsonToFeatureTree)))

lazy : (() -> Json.Decoder a) -> Json.Decoder a
lazy thunk =
  Json.customDecoder Json.value
  (\js -> Json.decodeValue (thunk ()) js)

-- UPDATE

type Action = RequestFeatures
            | UpdateFeatures (Result Error DT.DirectoryTree)

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    RequestFeatures ->
      (model, getFeaturesList model.url)
    UpdateFeatures resultFeatureTree ->
      case resultFeatureTree of
        Ok featureTree ->
          ( { model | features <- featureTree }
          , Effects.none
          )
        Err string ->
          let errorModel = { features = (DT.createNode "/I-errored" []), url = model.url }
              in (errorModel, Effects.none)

-- VIEW

view : Signal.Address Action -> Model -> Html
view address model = Html.div [] [ DT.view model.features ]
