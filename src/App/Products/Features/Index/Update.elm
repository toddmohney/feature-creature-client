module App.Products.Features.Index.Update exposing (..)

import App.AppConfig                           exposing (..)
-- import App.Products.Features.FeatureList as FL
import App.Products.Features.Requests as F
import App.Products.Features.Messages     exposing (Msg(..))
import App.Products.Features.Index.ViewModel   exposing (FeaturesView)
-- import App.Products.Navigation                 exposing (Action(..))
import Data.External                           exposing (External(..))
import Debug                                   exposing (crash, log)
-- import UI.SyntaxHighlighting as Highlight      exposing (highlightSyntaxMailbox)
-- import Task                                    exposing (..)

update : AppConfig -> Msg -> FeaturesView -> (FeaturesView, Cmd Msg)
update appConfig action featuresView =
  case action of
    RequestFeatures ->
      (featuresView, F.getFeaturesList appConfig featuresView.product Nothing)

    ShowFeatureDetails resultFeature ->
      case resultFeature of
        Ok feature ->
          ({ featuresView | selectedFeature = Just feature }, Cmd.none)
          -- ({ featuresView | selectedFeature = Just feature }
          -- , highlightFeatureSyntax
          -- )
        Err _ ->
          crash "Error handling FeaturesView.ShowFeatureDetails"

    SyntaxHighlightingAction _ -> (featuresView, Cmd.none)
      -- let highlightSyntax = Signal.send highlightSyntaxMailbox.address Nothing
      -- in ( featuresView
         -- , Effects.task <| highlightSyntax `andThen` (\_ -> (Task.succeed Noop))
         -- )

    UpdateFeatures query resultFeatureTree ->
      let newFeatureList    = case resultFeatureTree of
                                Ok featureTree -> Loaded { features = featureTree }
                                Err _ -> LoadedWithError "An error occurred while loading features"
          currentProduct    = featuresView.product
          newCurrentProduct = { currentProduct | featureList = newFeatureList }
          newFeaturesView   = { featuresView | product = newCurrentProduct, currentSearchTerm = query }
      in
        ( newFeaturesView
        , Cmd.none
        )
        -- this can't work. refactor Messages to past tense reports of what
        -- happend rather than commands of what to do next
        --
        -- ( newFeaturesView
        -- , Cmd.map (\_ -> SelectFeaturesView) Cmd.none
        -- )

    -- NavigationAction navAction ->
      -- case navAction of
        -- Navigation.SelectFeaturesView -> (featuresView, highlightFeatureSyntax)
        -- _                  -> (featuresView, Cmd.none)

    Noop -> ( featuresView, Cmd.none )

    ShowFeature fileDescription ->
      let product = featuresView.product
          filePath = fileDescription.filePath
          fx = F.getFeature appConfig product filePath
      in
        -- reset the current feature until the request comes back
        -- we need this to avoid appending to the view rather than
        -- replacing it.
        -- https://github.com/gust/feature-creature/issues/65
        ({ featuresView | selectedFeature = Nothing }, fx)

    _ -> (featuresView, Cmd.none)


-- highlightFeatureSyntax : Cmd Msg
-- highlightFeatureSyntax =
  -- Effects.task
    -- <| Task.succeed
    -- <| SyntaxHighlightingAction Highlight.HighlightSyntax
