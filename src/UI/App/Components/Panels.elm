module UI.App.Components.Panels exposing ( panelWithHeading )

import Html exposing (Html)
import UI.Bootstrap.Components.Panels as BS

panelWithHeading : Html a -> Html a -> Html a
panelWithHeading = BS.panelWithHeading
