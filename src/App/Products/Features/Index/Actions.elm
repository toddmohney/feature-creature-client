module App.Products.Features.Index.Actions where

import App.Products.Features.FeatureList as FL
import App.Products.Features.Feature           exposing (Feature)
import App.Products.Navigation as Navigation
import App.Search.Types                        exposing (Query)
import Data.DirectoryTree                      exposing (DirectoryTree)
import Http                                    exposing (..)
import UI.SyntaxHighlighting as Highlight

type Action = FeatureListAction FL.Action
            | Noop
            | RequestFeatures
            | ShowFeatureDetails (Result Error Feature)
            | SyntaxHighlightingAction Highlight.Action
            | UpdateFeatures (Maybe Query) (Result Error DirectoryTree)
            | NavigationAction Navigation.Action

