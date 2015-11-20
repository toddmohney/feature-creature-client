module Style where
import Html            exposing (Attribute)
import Html.Attributes exposing (..)

primaryBtn : Attribute
primaryBtn = classList [ ("btn", True)
                       , ("btn-primary", True)
                       ]
