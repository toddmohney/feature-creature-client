module Style where
import Html            exposing (Attribute)
import Html.Attributes exposing (..)

btn : Attribute
btn = classList [ ("btn", True) ]

primaryBtn : Attribute
primaryBtn = classList [ ("btn", True)
                       , ("btn-primary", True)
                       ]

panelDefault : Attribute
panelDefault = classList [ ("panel", True)
                         , ("panel-default", True)
                         ]

panelHeading : Attribute
panelHeading = classList [ ("panel-heading", True) ]

panelTitle : Attribute
panelTitle = classList [ ("panel-title", True) ]

panelBody : Attribute
panelBody = classList [ ("panel-body", True) ]
