module App.Products.Features.Index.ViewModel exposing (..)

import App.AppConfig                       exposing (..)
import App.Products.Product                exposing (Product, RepositoryState (..))
import App.Products.Features.Feature as F  exposing (..)
import App.Products.Features.Index.Actions exposing (Action(UpdateFeatures))
import App.Products.Features.Requests as F exposing (getFeaturesList)
import App.Products.Features.Index.Actions exposing (Action(..))
import App.Search.Types                    exposing (Query)

type alias FeaturesView =
  { product               : Product
  , selectedFeature       : Maybe Feature
  , currentSearchTerm     : Maybe Query
  }

init : AppConfig -> Product -> (FeaturesView, Effects Action)
init appConfig prod =
  let query        = Nothing
      action       = UpdateFeatures query
      featuresView = { product           = prod
                     , selectedFeature   = Nothing
                     , currentSearchTerm = query
                     }
      fx = case prod.repoState of
             Error   -> Effects.none
             Unready -> Effects.none
             Ready   -> getFeaturesList appConfig prod query action
  in
    (featuresView, fx)
