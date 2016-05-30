module Main exposing (..)

import App.App  as App
import App.Update  as App
import App.AppConfig      exposing (..)
import Html.App as Html

main : Program AppConfig
main = Html.programWithFlags
  { init   = App.init
  , update = App.update
  , view   = App.view
  , subscriptions = (\_ -> Sub.none)
  }
