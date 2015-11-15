module Feature where

import Html exposing (..)

type alias Feature = { featureID : String
                     , description : String
                     }

-- VIEW

view : Feature -> Html
view feature = Html.div [] [ text "hi" ]
