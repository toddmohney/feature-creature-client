module UI.Bootstrap.CSS.Buttons exposing (..)

import Html            exposing (Attribute)
import Html.Attributes exposing (..)

btn : Attribute a
btn = class "btn"

primaryBtn : Attribute a
primaryBtn = classList [ ("btn", True)
                       , ("btn-primary", True)
                       ]

secondaryBtn : Attribute a
secondaryBtn = classList [ ("btn", True)
                         , ("btn-default", True)
                         , ("btn-xs", True)
                         ]
