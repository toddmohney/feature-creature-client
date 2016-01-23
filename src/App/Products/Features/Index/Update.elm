module App.Products.Features.Index.Update where

import App.Products.Features.FeatureList as FL
import App.Products.Features.Index.Actions     exposing (Action(..))
import App.Products.Features.Index.ViewModel   exposing (FeaturesView, featureUrl, featuresUrl, getFeature, getFeaturesList)
import App.Products.Navigation as Navigation
import Debug                                   exposing (crash, log)
import Effects                                 exposing (Effects)
import UI.SyntaxHighlighting as Highlight      exposing (highlightSyntaxMailbox)
import Task                                    exposing (..)

update : Action -> FeaturesView -> (FeaturesView, Effects Action)
update action productView =
  case action of
    FeatureListAction featureListAction ->
      case featureListAction of
        FL.ShowFeature fileDescription ->
          (productView, getFeature (featureUrl productView.product fileDescription.filePath))

    Noop ->
      ( productView, Effects.none )

    RequestFeatures ->
      (productView, getFeaturesList (featuresUrl productView.product Nothing))

    ShowFeatureDetails resultFeature ->
      case resultFeature of
        Ok feature ->
          ({ productView | selectedFeature = Just feature }
          , Effects.task
              <| Task.succeed
              <| SyntaxHighlightingAction Highlight.HighlightSyntax
          )
        Err _ ->
          crash "Error handling FeaturesView.ShowFeatureDetails"

    SyntaxHighlightingAction _ ->
      let highlightSyntax = Signal.send highlightSyntaxMailbox.address Nothing
      in ( productView
         , Effects.task <| highlightSyntax `andThen` (\_ -> (Task.succeed Noop))
         )

    UpdateFeatures resultFeatureTree ->
      case resultFeatureTree of
        Ok featureTree ->
          let newFeatureList = Just { features = featureTree }
              currentProduct = productView.product
              newFeaturesView = { productView | product = { currentProduct | featureList = newFeatureList } }
            in ( newFeaturesView
               , Effects.task (Task.succeed (NavigationAction Navigation.SelectFeaturesView))
               )
        Err _ -> crash "Error handling FeaturesView.UpdateFeatures"


    NavigationAction a ->
      let thingy = log "NavigationAction: " a
      in (productView, Effects.none)
