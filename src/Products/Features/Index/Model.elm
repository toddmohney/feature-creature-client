module Products.Features.Index.Model where

import Data.DirectoryTree as DT
import Effects exposing (Effects)
import Http                                   exposing (..)
import Json.Decode as Json                    exposing ((:=))
import Products.Product                       exposing (Product)
import Products.Features.Feature as F         exposing (..)
import Products.Features.Index.Actions        exposing (Action(..))
import Task                                   exposing (..)

type alias FeaturesView =
  { product               : Product
  , selectedFeature       : Maybe Feature
  }

init : Product -> (FeaturesView, Effects Action)
init prod =
  let productView = { product               = prod
                    , selectedFeature       = Nothing
                    }
  in (productView , getFeaturesList (featuresUrl prod))

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

featuresUrl : Product -> String
featuresUrl product = "http://localhost:8081/products/" ++ (toString product.id) ++ "/features"

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
