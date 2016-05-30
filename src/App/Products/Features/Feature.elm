module App.Products.Features.Feature exposing
  ( Feature
  , view
  )

import Html exposing (..)
import Html.Attributes exposing (classList)

type alias Feature =
  { featureID : String
  , description : String
  }

view : Feature -> Html a
view feature =
  Html.pre
  []
  [ Html.code
    [ classes ]
    [ text feature.description ]
  ]

classes : Attribute a
classes = classList [ ("language-gherkin", True)
                    , ("lang-gherkin", True)
                    , ("gherkin", True)
                    , ("feature-detail", True)
                    ]
