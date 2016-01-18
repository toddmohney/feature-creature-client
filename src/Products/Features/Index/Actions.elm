module Products.Features.Index.Actions where

import Data.DirectoryTree                  exposing (DirectoryTree)
import Http                                exposing (..)
import Products.Features.FeatureList as FL
import Products.Features.Feature           exposing (Feature)
import Products.Navigation as Navigation
import UI.SyntaxHighlighting as Highlight

type Action = FeatureListAction FL.Action
            | Noop
            | RequestFeatures
            | ShowFeatureDetails (Result Error Feature)
            | SyntaxHighlightingAction Highlight.Action
            | UpdateFeatures (Result Error DirectoryTree)
            | NavigationAction Navigation.Action

