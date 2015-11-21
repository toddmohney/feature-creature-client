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
            | ShowDomainTermForm

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
          crash "Error handling ProductView.UpdateFeatures"
    FeatureListAction featureListAction ->
      case featureListAction of
        ShowFeature fileDescription ->
          (productView, getFeature (featureUrl productView.product fileDescription.filePath))
    ShowFeatureDetails resultFeature ->
      case resultFeature of
        Ok feature ->
          ({ productView | feature <- Just feature }, Effects.none)
        Err _ ->
          crash "Error handling ProductView.ShowFeatureDetails"
    ShowDomainTermForm ->
      crash "ShowDomainTermForm is unimplemented"

-- yikes. this is a mess
view : Signal.Address Action -> ProductView -> Html
view address productView =
  case productView.featureList of
    Nothing ->
      Html.div [] [ text "missing featureList! (ProductView)" ]
    Just featureList ->
      let featureListAddress = (Signal.forwardTo address FeatureListAction)
      in case productView.feature of
        Just feature ->
          Html.div
          [ id "product_view" ]
          [ Html.div
              [ class "pull-left" ]
              [ FL.render featureListAddress featureList
              , showDomainTermForm address
              ]
          , Html.div
              [ class "pull-right" ]
              [ F.view feature ]
          ]
        Nothing ->
          Html.div
          [ id "product_view" ]
          [ Html.div
              [ class "pull-left" ]
              [ FL.render featureListAddress featureList
              , showDomainTermForm address
              ]
          , Html.div
              [ class "pull-right" ]
              [ ]
          ]

showDomainTermForm : Signal.Address Action -> Html
showDomainTermForm address =
  Html.a
  [ href "#", onClick address ShowDomainTermForm ]
  [ text "Create Domain Term" ]
