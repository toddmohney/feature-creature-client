module Data.Actions where

type alias ForwardedAction a =
  { address : Signal.Address a
  , action  : a
  }
