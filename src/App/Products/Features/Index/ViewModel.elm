module App.Products.Features.Index.ViewModel where

import App.Products.Product                exposing (Product)
import App.Products.Features.Feature as F  exposing (..)
import App.Products.Features.Index.Actions exposing (Action(..))
import App.Search.Types as Search
import Data.DirectoryTree as DT
import Effects                             exposing (Effects)
import Http                                exposing (..)
import Json.Decode as Json                 exposing ((:=))
import Task                                exposing (..)

type alias FeaturesView =
  { product               : Product
  , selectedFeature       : Maybe Feature
  }

init : Product -> (FeaturesView, Effects Action)
init prod =
  let featuresView = { product        = prod
                     , selectedFeature = Nothing
                     }
  in (featuresView , getFeaturesList (featuresUrl prod Nothing))

-- this doesn't feel like it belongs in the Model module
getFeaturesList : String -> Effects Action
getFeaturesList url =
   Http.get parseFeatureTree url
    |> Task.toResult
    |> Task.map UpdateFeatures
    |> Effects.task

-- this doesn't feel like it belongs in the Model module
getFeature : String -> Effects Action
getFeature url =
   Http.get parseFeature url
    |> Task.toResult
    |> Task.map ShowFeatureDetails
    |> Effects.task

parseFeature : Json.Decoder F.Feature
parseFeature =
  Json.object2 F.Feature
  ("featureID"   := Json.string)
  ("description" := Json.string)

parseFeatureTree : Json.Decoder DT.DirectoryTree
parseFeatureTree =
  Json.object2 DT.DirectoryTree
  ("fileDescription" := parseFileDescription)
  ("forest"          := Json.list (lazy (\_ -> parseFeatureTree)))

featuresUrl : Product -> Maybe Search.Query -> String
featuresUrl product query =
  let featuresEndpoint = "http://localhost:8081/products/" ++ (toString product.id) ++ "/features"
  in case query of
    Nothing  -> featuresEndpoint
    (Just q) -> featuresEndpoint ++ "?search=" ++ q.term

featureUrl : Product -> DT.FilePath -> String
featureUrl product path = "http://localhost:8081/products/" ++ (toString product.id) ++ "/feature?path=" ++ path

parseFileDescription : Json.Decoder DT.FileDescription
parseFileDescription =
  Json.object2 DT.FileDescription
  ("fileName" := Json.string)
  ("filePath" := Json.string)

lazy : (() -> Json.Decoder a) -> Json.Decoder a
lazy thunk =
  Json.customDecoder Json.value
  (\js -> Json.decodeValue (thunk ()) js)
