module App.Products.Features.Index.Update where

import App.AppConfig                           exposing (..)
import App.Products.Features.FeatureList as FL
import App.Products.Features.Requests as F
import App.Products.Features.Index.Actions     exposing (Action(..))
import App.Products.Features.Index.ViewModel   exposing (FeaturesView)
import App.Products.Navigation as Navigation
import Data.External                           exposing (External(..))
import Debug                                   exposing (crash, log)
import Effects                                 exposing (Effects)
import UI.SyntaxHighlighting as Highlight      exposing (highlightSyntaxMailbox)
import Task                                    exposing (..)

update : AppConfig -> Action -> FeaturesView -> (FeaturesView, Effects Action)
update appConfig action featuresView =
  case action of
    FeatureListAction featureListAction ->
      case featureListAction of
        FL.ShowFeature fileDescription ->
          let product = featuresView.product
              filePath = fileDescription.filePath
              fx = F.getFeature appConfig product filePath ShowFeatureDetails
          in
            -- reset the current feature until the request comes back
            -- we need this to avoid appending to the view rather than
            -- replacing it.
            -- https://github.com/gust/feature-creature/issues/65
            ({ featuresView | selectedFeature = Nothing }, fx)

    RequestFeatures ->
      let query = Nothing
          action = UpdateFeatures query
      in
        (,)
        featuresView
        (F.getFeaturesList appConfig featuresView.product query action)

    ShowFeatureDetails resultFeature ->
      case resultFeature of
        Ok feature ->
          ({ featuresView | selectedFeature = Just feature }
          , highlightFeatureSyntax
          )
        Err _ ->
          crash "Error handling FeaturesView.ShowFeatureDetails"

    SyntaxHighlightingAction _ ->
      let highlightSyntax = Signal.send highlightSyntaxMailbox.address Nothing
      in ( featuresView
         , Effects.task <| highlightSyntax `andThen` (\_ -> (Task.succeed Noop))
         )

    UpdateFeatures query resultFeatureTree ->
      let newFeatureList    = case resultFeatureTree of
                                Ok featureTree -> Loaded { features = featureTree }
                                Err _ -> LoadedWithError "An error occurred while loading features"
          currentProduct    = featuresView.product
          newCurrentProduct = { currentProduct | featureList = newFeatureList }
          newFeaturesView   = { featuresView | product = newCurrentProduct, currentSearchTerm = query }
      in
        ( newFeaturesView
        , Effects.task (Task.succeed (NavigationAction Navigation.SelectFeaturesView))
        )

    NavigationAction navAction ->
      case navAction of
        Navigation.SelectFeaturesView -> (featuresView, highlightFeatureSyntax)
        _                  -> (featuresView, Effects.none)

    Noop -> ( featuresView, Effects.none )

highlightFeatureSyntax : Effects Action
highlightFeatureSyntax =
  Effects.task
    <| Task.succeed
    <| SyntaxHighlightingAction Highlight.HighlightSyntax
