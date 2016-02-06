module App.Products.Features.Index.ViewModel where

import App.AppConfig                       exposing (..)
import App.Products.Product                exposing (Product)
import App.Products.Features.Feature as F  exposing (..)
import App.Products.Features.Index.Actions exposing (Action(UpdateFeatures))
import App.Products.Features.Requests as F exposing (getFeaturesList)
import App.Products.Features.Index.Actions exposing (Action(..))
import Effects                             exposing (Effects)

type alias FeaturesView =
  { product               : Product
  , selectedFeature       : Maybe Feature
  }

init : AppConfig -> Product -> (FeaturesView, Effects Action)
init appConfig prod =
  let featuresView = { product        = prod
                     , selectedFeature = Nothing
                     }
      query = Nothing
      action = UpdateFeatures query
  in
    (,)
    featuresView
    (getFeaturesList appConfig prod query action)
