module App.Products.Features.Index.Update exposing ( update )

import App.AppConfig                           exposing (..)
import App.Products.Features.Requests as F
import App.Products.Features.Messages     exposing (Msg(..))
import App.Products.Features.Index.ViewModel   exposing (FeaturesView)
import Data.External                           exposing (External(..))
import Debug                                   exposing (crash, log)
import Ports exposing (highlightSyntax)

update : AppConfig -> Msg -> FeaturesView -> (FeaturesView, Cmd Msg)
update appConfig action featuresView =
  case log "features.index.view: " action of
    FetchFeaturesSucceeded query featureTree ->
      let newFeatureList    = Loaded { features = featureTree }
          currentProduct    = featuresView.product
          newCurrentProduct = { currentProduct | featureList = newFeatureList }
          newFeaturesView   = { featuresView | product = newCurrentProduct, currentSearchTerm = query }
      in
        (newFeaturesView , Cmd.none)

    FetchFeatureSucceeded feature ->
      ({ featuresView | selectedFeature = Just feature }
      , highlightSyntax "dummy"
      )

    FetchFeaturesFailed err -> crash "Failed to load feature list"
    FetchFeatureFailed err  -> crash "Failed to load feature list"

    RequestFeatures ->
      (featuresView, F.getFeaturesList appConfig featuresView.product Nothing)

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
