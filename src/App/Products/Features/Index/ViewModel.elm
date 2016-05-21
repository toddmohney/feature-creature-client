module App.Products.Features.Index.ViewModel exposing (..)

import App.AppConfig                  exposing (..)
import App.Products.Product           exposing (Product, RepositoryState (..))
import App.Products.Features.Feature  exposing (..)
import App.Products.Features.Messages exposing (Msg(..))
import App.Products.Features.Requests exposing (getFeaturesList)
import App.Search.Types               exposing (Query)

type alias FeaturesView =
  { product               : Product
  , selectedFeature       : Maybe Feature
  , currentSearchTerm     : Maybe Query
  }

init : AppConfig -> Product -> (FeaturesView, Cmd Msg)
init appConfig prod =
  let query        = Nothing
      featuresView = { product           = prod
                     , selectedFeature   = Nothing
                     , currentSearchTerm = query
                     }
      fx = case prod.repoState of
             Error   -> Effects.none
             Unready -> Effects.none
             Ready   -> getFeaturesList appConfig prod query
  in
    (featuresView, fx)
