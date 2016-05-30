module UI.Bootstrap.CSS.Panels exposing (..)

import Html            exposing (Attribute)
import Html.Attributes exposing (..)

panelDefault : Attribute a
panelDefault = classList [ ("panel", True)
                         , ("panel-default", True)
                         ]

panelHeading : Attribute a
panelHeading = classList [ ("panel-heading", True) ]

panelTitle : Attribute a
panelTitle = classList [ ("panel-title", True) ]

panelBody : Attribute a
panelBody = classList [ ("panel-body", True) ]
