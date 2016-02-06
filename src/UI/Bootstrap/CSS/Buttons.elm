module UI.Bootstrap.CSS.Buttons where

import Html            exposing (Attribute)
import Html.Attributes exposing (..)

btn : Attribute
btn = class "btn"

primaryBtn : Attribute
primaryBtn = classList [ ("btn", True)
                       , ("btn-primary", True)
                       ]

secondaryBtn : Attribute
secondaryBtn = classList [ ("btn", True) ]
