module Products.ProductView where

import Debug exposing (crash)
import Data.DirectoryTree as DT
import Effects exposing (Effects)
import Products.DomainTerms.DomainTerm exposing (..)
import Products.Features.Feature as F exposing (..)
import Products.Features.FeatureList as FL exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http exposing (..)
import Json.Decode as Json exposing ((:=))
import Products.Product exposing (..)
import Task exposing (..)


type alias ProductView =
  { product     : Product
  , featureList : Maybe FeatureList
  , feature     : Maybe Feature
  , domainTerms : List DomainTerm
  }

type Action = RequestFeatures
            | UpdateFeatures (Result Error DT.DirectoryTree)
            | ShowFeatureDetails (Result Error Feature)
            | FeatureListAction FL.Action

init : Product -> (ProductView, Effects Action)
init prod =
  let productView = { product     = prod
                    , featureList = Nothing
                    , feature     = Nothing
                    , domainTerms = []
                    }
  in (productView , getFeaturesList (featuresUrl prod))

getFeaturesList : String -> Effects Action
getFeaturesList url =
   Http.get parseFeatureTree url
    |> Task.toResult
    |> Task.map UpdateFeatures
    |> Effects.task

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

update : Action -> ProductView -> (ProductView, Effects Action)
update action productView =
  case action of
    RequestFeatures ->
      (productView, getFeaturesList (featuresUrl productView.product))
    UpdateFeatures resultFeatureTree ->
      case resultFeatureTree of
        Ok featureTree ->
          let featureList = { features = featureTree }
              newProductView = { productView | featureList <- Just featureList }
            in (newProductView, Effects.none)
        Err _ ->
          let errorFileDescription = DT.createNode { fileName = "/I-errored", filePath = "/I-errored" } []
              featureList = { features = errorFileDescription }
              errorModel = { product = productView.product
                           , featureList = Just featureList
                           , feature = Nothing
                           , domainTerms = []
                           }
            in (errorModel, Effects.none)
    FeatureListAction featureListAction ->
      case featureListAction of
        ShowFeature fileDescription ->
          (productView, getFeature (featureUrl productView.product fileDescription.filePath))
    ShowFeatureDetails resultFeature ->
      case resultFeature of
        Ok feature ->
          ({ productView | feature <- Just feature }, Effects.none)
        Err _ ->
          let errorFeature = { featureID = "uh oh!", description = "Something went wrong!" }
          in ({ productView | feature <- Just errorFeature }, Effects.none)

view : Signal.Address Action -> ProductView -> Html
view address productView =
  case productView.featureList of
    Nothing ->
      div [] [ text "missing featureList! (ProductView)" ]
    Just featureList ->
      case productView.feature of
        Just feature ->
          div
          [ id "product_view" ]
          [
            Html.div
              [ class "pull-left" ]
              [ FL.render (Signal.forwardTo address FeatureListAction) featureList ]
          , Html.div
              [ class "pull-right" ]
              [ F.view feature ]
          ]
        Nothing ->
          div
          [ id "product_view" ]
          [
            Html.div
              [ class "pull-left" ]
              [ FL.render (Signal.forwardTo address FeatureListAction) featureList ]
          ]
