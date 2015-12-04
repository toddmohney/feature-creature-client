module UI.App.Components.Panels
  ( panelWithHeading
  ) where

import Html exposing (Html)
import UI.Bootstrap.Components.Panels as BS

panelWithHeading : Html -> Html -> Html
panelWithHeading = BS.panelWithHeading
