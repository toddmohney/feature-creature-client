module App.Products.Features.Index.View where

import App.Products.Features.Feature as F
import App.Products.Features.FeatureList as FL
import App.Products.Features.Index.Actions   exposing (Action(..))
import App.Products.Features.Index.ViewModel exposing (FeaturesView)
import Html                                  exposing (..)
import UI.App.Components.ListDetailView as UI

view : Signal.Address Action -> FeaturesView -> Html
view address featuresView =
  case featuresView.product.featureList of
    Nothing ->
      Html.div [] [ text "missing featureList! (FeaturesView)" ]
    Just featureList ->
      let featureListAddress = Signal.forwardTo address FeatureListAction
          featureHtml = case featuresView.selectedFeature of
            Just feature -> [ F.view feature ]
            Nothing      -> []
          listHtml = [ FL.render featureListAddress featureList ]
      in UI.listDetailView listHtml featureHtml

