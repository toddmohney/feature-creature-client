module App.Products.Features.Requests exposing
  ( getFeaturesList
  , getFeature
  )

import App.AppConfig                       exposing (..)
import App.Products.Features.Feature       exposing (Feature)
import App.Products.Features.Messages      exposing (Msg(..))
import App.Products.Product                exposing (Product)
import App.Search.Types as Search
import Data.DirectoryTree as DT            exposing (DirectoryTree)
import Http                                exposing (..)
import Json.Decode as Json                 exposing ((:=))
import Task                                exposing (..)

getFeaturesList : AppConfig
               -> Product
               -> Maybe Search.Query
               -> Cmd Msg
getFeaturesList appConfig product query =
  featuresUrl appConfig product query
    |> Http.get DT.parseFeatureTree
    |> Task.perform FetchFeaturesFailed (FetchFeaturesSucceeded query)

getFeature : AppConfig
          -> Product
          -> DT.FilePath
          -> Cmd Msg
getFeature appConfig product path =
  featureUrl appConfig product path
    |> Http.get parseFeature
    |> Task.perform FetchFeatureFailed FetchFeatureSucceeded

featuresUrl : AppConfig
           -> Product
           -> Maybe Search.Query
           -> String
featuresUrl appConfig product query =
  let featuresEndpoint = appConfig.apiPath ++ "/products/" ++ (toString product.id) ++ "/features"
  in
    case query of
      Nothing  -> featuresEndpoint
      (Just q) -> featuresEndpoint ++ "?search=" ++ q.term

featureUrl : AppConfig
          -> Product
          -> DT.FilePath
          -> String
featureUrl appConfig product path =
  appConfig.apiPath ++ "/products/" ++ (toString product.id) ++ "/feature?path=" ++ path

parseFeature : Json.Decoder Feature
parseFeature =
  Json.object2 Feature
    ("featureID"   := Json.string)
    ("description" := Json.string)
