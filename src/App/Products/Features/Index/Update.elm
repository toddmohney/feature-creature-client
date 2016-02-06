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
update appConfig action productView =
  case action of
    FeatureListAction featureListAction ->
      case featureListAction of
        FL.ShowFeature fileDescription ->
          let product = productView.product
              filePath = fileDescription.filePath
              fx = F.getFeature appConfig product filePath ShowFeatureDetails
          in
            (productView, fx)

    RequestFeatures ->
      let query = Nothing
          action = UpdateFeatures query
      in
        (,)
        productView
        (F.getFeaturesList appConfig productView.product query action)

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

    UpdateFeatures query resultFeatureTree ->
      let newFeatureList = case resultFeatureTree of
                             Ok featureTree -> Loaded { features = featureTree }
                             Err _ -> LoadedWithError "An error occurred while loading features"
          currentProduct = productView.product
          newFeaturesView = { productView | product = { currentProduct | featureList = newFeatureList } }
      in
        ( newFeaturesView
        , Effects.task (Task.succeed (NavigationAction Navigation.SelectFeaturesView))
        )

    Noop -> ( productView, Effects.none )

    NavigationAction a -> (productView, Effects.none)
