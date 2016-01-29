module App.Products.Features.Index.View where

import App.Products.Features.Feature as F
import App.Products.Features.FeatureList as FL
import App.Products.Features.Index.Actions   exposing (Action(..))
import App.Products.Features.Index.ViewModel exposing (FeaturesView)
import Data.External                         exposing (External(..))
import Html                                  exposing (..)
import UI.App.Components.ListDetailView as UI

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
        in UI.listDetailView listHtml featureHtml

