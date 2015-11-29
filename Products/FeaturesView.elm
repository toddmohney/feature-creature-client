module Products.FeaturesView where

import Debug                                  exposing (crash)
import Data.DirectoryTree as DT
import Effects                                exposing (Effects)
import Products.Features.Feature as F         exposing (..)
import Products.Features.FeatureList as FL    exposing (..)
import Html                                   exposing (..)
import Http                                   exposing (..)
import Interop                                exposing (highlightSyntaxMailbox)
import Json.Decode as Json                    exposing ((:=))
import Products.Product                       exposing (..)
import Task                                   exposing (..)
import UI.App.Components.ListDetailView as UI

type alias FeaturesView =
  { product               : Product
  , selectedFeature       : Maybe Feature
  }

type Action = RequestFeatures
            | UpdateFeatures (Result Error DT.DirectoryTree)
            | ShowFeatureDetails (Result Error Feature)
            | FeatureListAction FL.Action
            | InteropAction Interop.Action
            | Noop

init : Product -> (FeaturesView, Effects Action)
init prod =
  let productView = { product               = prod
                    , selectedFeature       = Nothing
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

update : Action -> FeaturesView -> (FeaturesView, Effects Action)
update action productView =
  case action of
    RequestFeatures ->
      (productView, getFeaturesList (featuresUrl productView.product))

    UpdateFeatures resultFeatureTree ->
      case resultFeatureTree of
        Ok featureTree ->
          let newFeatureList = Just { features = featureTree }
              currentProduct = productView.product
              newFeaturesView = { productView | product = { currentProduct | featureList = newFeatureList } }
            in (newFeaturesView, Effects.none)
        Err _ -> crash "Error handling FeaturesView.UpdateFeatures"

    FeatureListAction featureListAction ->
      case featureListAction of
        ShowFeature fileDescription ->
          (productView, getFeature (featureUrl productView.product fileDescription.filePath))

    ShowFeatureDetails resultFeature ->
      case resultFeature of
        Ok feature ->
          ({ productView | selectedFeature = Just feature }
          , Effects.task
              <| Task.succeed
              <| InteropAction Interop.HighlightSyntax
          )
        Err _ ->
          crash "Error handling FeaturesView.ShowFeatureDetails"

    InteropAction _ ->
      let highlightSyntax = Signal.send highlightSyntaxMailbox.address Nothing
      in ( productView
         , Effects.task <| highlightSyntax `andThen` (\_ -> (Task.succeed Noop))
         )

    Noop ->
      ( productView, Effects.none )

view : Signal.Address Action -> FeaturesView -> Html
view address productView =
  case productView.product.featureList of
    Nothing ->
      Html.div [] [ text "missing featureList! (FeaturesView)" ]
    Just featureList ->
      let featureListAddress = (Signal.forwardTo address FeatureListAction)
          featureHtml = case productView.selectedFeature of
            Just feature ->
              [ F.view feature ]
            Nothing ->
              []
          listHtml = [ FL.render featureListAddress featureList ]
      in UI.listDetailView listHtml featureHtml

