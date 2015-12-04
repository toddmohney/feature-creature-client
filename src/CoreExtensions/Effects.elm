module CoreExtensions.Effects where

import Effects                           exposing (Effects)

batchEffects : List (Effects a) -> Effects a
batchEffects effects =
  if List.isEmpty effects
  then Effects.none
  else Effects.batch effects

