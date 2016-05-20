module App.Products.Features.Feature exposing (..)

import Html                                exposing (..)
import Html.Attributes                     exposing (classList)

type alias Feature =
  { featureID : String
  , description : String
  }

view : Feature -> Html
view feature =
  let classes = classList [ ("language-gherkin", True)
                          , ("lang-gherkin", True)
                          , ("gherkin", True)
                          , ("feature-detail", True)
                          ]
  in
    Html.pre
    []
    [ Html.code
      [ classes ]
      [ text feature.description ]
    ]
