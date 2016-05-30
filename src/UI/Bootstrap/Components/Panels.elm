module UI.Bootstrap.Components.Panels exposing ( panelWithHeading )

import Html exposing (Html)
import UI.Bootstrap.CSS.Panels as BS

panelWithHeading : Html a -> Html a -> Html a
panelWithHeading headingContent bodyContent =
  Html.div
    [ BS.panelDefault ]
    [ panelHeading headingContent
    , panelBody bodyContent
    ]

panelHeading : Html a -> Html a
panelHeading content =
  Html.div
    [ BS.panelHeading ]
    [ Html.h3
        [ BS.panelTitle ]
        [ content ]
    ]

panelBody : Html a -> Html a
panelBody bodyContent =
  Html.div
    [ BS.panelBody ]
    [ bodyContent ]
