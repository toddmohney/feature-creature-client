module UI.Bootstrap.CSS.Panels exposing (..)

import Html            exposing (Attribute)
import Html.Attributes exposing (..)

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
