module App.Products.Features.Index.View where

import App.Products.Features.Feature as F
import App.Products.Features.FeatureList as FL
import App.Products.Features.Index.Actions   exposing (Action(..))
import App.Products.Features.Index.ViewModel exposing (FeaturesView)
import App.Search.Types                      exposing (..)
import Data.External                         exposing (External(..))
import Html                                  exposing (..)
import Html.Attributes                       exposing (classList)
import Html.Events                           exposing (onClick)
import UI.App.Components.ListDetailView as UI
import UI.App.Primitives.Buttons as UI

view : Signal.Address Action -> FeaturesView -> Html
view address featuresView =
  let featureList = featuresView.product.featureList
  in
    case featureList of
      NotLoaded           -> Html.div [] [ text "Loading feature list..." ]
      LoadedWithError err -> Html.div [] [ text err ]
      Loaded featureList  ->
        let featureListAddress = Signal.forwardTo address FeatureListAction
            featureHtml = case featuresView.selectedFeature of
              Just feature -> [ F.view feature ]
              Nothing      -> []
            listHtml = [ FL.render featureListAddress featureList ]
        in
          case featuresView.currentSearchTerm of
            Nothing ->
              let listDetailView = UI.listDetailView listHtml featureHtml
              in
                renderListDetailView listDetailView
            Just query ->
              let listHtmlWithSearchFilterIndicator = ((renderCurrentSearchTerm query address) :: listHtml)
                  listDetailView = UI.listDetailView listHtmlWithSearchFilterIndicator featureHtml
              in
                renderListDetailView listDetailView

renderListDetailView : Html -> Html
renderListDetailView listDetailView =
  Html.div
  []
  [ listDetailView ]

renderCurrentSearchTerm : Query -> Signal.Address Action -> Html
renderCurrentSearchTerm query address =
  Html.div
  [ (classList [ ("well", True), ("well-sm", True) ]) ]
  [ (Html.text ("Filtered by: " ++ query.datatype ++ ": " ++ query.term ++ " "))
  , (UI.secondaryBtn [(onClick address RequestFeatures)] "Clear")
  ]
