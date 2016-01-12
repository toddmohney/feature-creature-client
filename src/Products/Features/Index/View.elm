module Products.Features.Index.View where

import Html                                   exposing (..)
import Products.Features.Feature as F
import Products.Features.FeatureList as FL
import Products.Features.Index.Actions        exposing (Action(..))
import Products.Features.Index.ViewModel      exposing (FeaturesView)
import UI.App.Components.ListDetailView as UI

view : Signal.Address Action -> FeaturesView -> Html
view address productView =
  case productView.product.featureList of
    Nothing ->
      Html.div [] [ text "missing featureList! (FeaturesView)" ]
    Just featureList ->
      let featureListAddress = Signal.forwardTo address FeatureListAction
          featureHtml = case productView.selectedFeature of
            Just feature -> [ F.view feature ]
            Nothing      -> []
          listHtml = [ FL.render featureListAddress featureList ]
      in UI.listDetailView listHtml featureHtml

