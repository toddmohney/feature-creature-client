module App.Products.Features.Feature where

import Html                                exposing (..)
import Html.Attributes                     exposing (class)

type alias Feature =
  { featureID : String
  , description : String
  }

view : Feature -> Html
view feature =
  Html.pre
  []
  [ Html.code
    [ class "language-gherkin" ]
    [ text feature.description ]
  ]
