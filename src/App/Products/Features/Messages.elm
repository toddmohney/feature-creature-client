module App.Products.Features.Messages exposing (Msg(..))

import App.Products.Features.Feature           exposing (Feature)
-- import App.Products.Navigation as Navigation
import App.Search.Types                        exposing (Query)
import Data.DirectoryTree                      exposing (DirectoryTree)
import Http                                    exposing (..)
import UI.SyntaxHighlighting as Highlight

type Msg = ShowFeature FileDescription
         | Noop
         | RequestFeatures
         | ShowFeatureDetails (Result Error Feature)
         | SyntaxHighlightingAction Highlight.Action
         | UpdateFeatures (Maybe Query) (Result Error DirectoryTree)
         | FetchFeaturesSucceeded DirectoryTree
         | FetchFeaturesFailed Error
         | FetchFeatureSucceeded Feature
         | FetchFeatureFailed Error
         -- | NavigationAction Navigation.Action

