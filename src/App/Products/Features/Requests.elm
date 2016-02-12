module App.Products.Features.Requests
  ( getFeaturesList
  , getFeature
  ) where

import App.AppConfig                       exposing (..)
import App.Products.Features.Feature       exposing (Feature)
import App.Products.Product                exposing (Product)
import App.Search.Types as Search
import Data.DirectoryTree as DT            exposing (DirectoryTree)
import Effects                             exposing (Effects)
import Http                                exposing (..)
import Json.Decode as Json                 exposing ((:=))
import Task                                exposing (..)

getFeaturesList : AppConfig
               -> Product
               -> Maybe Search.Query
               -> (Result Error DirectoryTree -> a)
               -> Effects a
getFeaturesList appConfig product query action =
  let url = featuresUrl appConfig product query
  in
    Http.get DT.parseFeatureTree url
      |> Task.toResult
      |> Task.map action
      |> Effects.task


getFeature : AppConfig
          -> Product
          -> DT.FilePath
          -> (Result Error Feature -> a)
          -> Effects a
getFeature appConfig product path action =
  let url = featureUrl appConfig product path
  in
    Http.get parseFeature url
      |> Task.toResult
      |> Task.map action
      |> Effects.task


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
