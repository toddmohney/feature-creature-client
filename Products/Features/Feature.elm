module Products.Features.Feature where

import Html exposing (..)

type alias Feature = { featureID : String
                     , description : String
                     }

view : Feature -> Html
view feature = Html.pre [] [ text feature.description ]
