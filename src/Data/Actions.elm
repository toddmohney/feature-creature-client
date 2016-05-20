module Data.Actions exposing (..)

type alias ForwardedAction a =
  { address : Signal.Address a
  , action  : a
  }
