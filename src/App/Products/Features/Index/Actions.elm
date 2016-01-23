module App.Products.Features.Index.Actions where

import App.Products.Features.FeatureList as FL
import App.Products.Features.Feature           exposing (Feature)
import App.Products.Navigation as Navigation
import Data.DirectoryTree                      exposing (DirectoryTree)
import Http                                    exposing (..)
import UI.SyntaxHighlighting as Highlight

type Action = FeatureListAction FL.Action
            | Noop
            | RequestFeatures
            | ShowFeatureDetails (Result Error Feature)
            | SyntaxHighlightingAction Highlight.Action
            | UpdateFeatures (Result Error DirectoryTree)
            | NavigationAction Navigation.Action

