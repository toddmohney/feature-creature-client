module ProductView where

import Debug exposing (crash)
import DirectoryTree as DT
import Effects exposing (Effects)
import Feature as F exposing (..)
import FeatureList exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http exposing (..)
import Json.Decode as Json exposing ((:=))
import Product exposing (..)
import Task exposing (..)


type alias ProductView =
  { product     : Product
  , featureList : Maybe FeatureList
  , feature     : Maybe Feature
  }

type Action = RequestFeatures
            | UpdateFeatures (Result Error DT.DirectoryTree)
            | ShowFeature DT.FileDescription
            | ShowFeatureDetails (Result Error Feature)

init : Product -> (ProductView, Effects Action)
init prod =
  let productView = { product     = prod
                    , featureList = Nothing
                    , feature     = Nothing
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
                           }
            in (errorModel, Effects.none)
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
            renderFeatureList address featureList,
            Html.div [ class "pull-right" ] [ F.view feature ]
          ]
        Nothing ->
          div
          [ id "product_view" ]
          [ renderFeatureList address featureList ]

renderFeatureList : Signal.Address Action -> FeatureList -> Html
renderFeatureList address featureList =
  Html.div
  [ class "pull-left" ]
  [ drawFeatureFiles address featureList.features ]

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
