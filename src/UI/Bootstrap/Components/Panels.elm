module UI.Bootstrap.Components.Panels
  ( panelWithHeading
  ) where

import Html exposing (Html)
import Html.Attributes
import UI.Bootstrap.CSS.Panels as BS

panelWithHeading : Html -> Html -> Html
panelWithHeading headingContent bodyContent =
  Html.div
    [ BS.panelDefault ]
    [ panelHeading headingContent
    , panelBody bodyContent
    ]

panelHeading : Html -> Html
panelHeading content =
  Html.div
    [ BS.panelHeading ]
    [ Html.h3
        [ BS.panelTitle ]
        [ content ]
    ]

panelBody : Html -> Html
panelBody bodyContent =
  Html.div
    [ BS.panelBody ]
    [ bodyContent ]
