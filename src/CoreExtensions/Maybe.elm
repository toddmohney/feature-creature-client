module CoreExtensions.Maybe exposing (..)

import Debug exposing (crash)

fromJust : Maybe a -> a
fromJust maybe =
  case maybe of
    Just a -> a
    Nothing -> crash "Error: Cannot call `fromJust` with Nothing"
