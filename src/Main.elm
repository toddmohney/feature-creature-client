module Main exposing (..)

import App.App  as App
import App.Messages exposing (Msg, Msg (AuthenticationActions))
import App.Update  as App
import App.AppConfig exposing (..)
import Auth
import Html.App as Html
import Ports

main : Program AppConfig
main = Html.programWithFlags
  { init   = App.init
  , update = App.update
  , view   = App.view
  , subscriptions = subscriptions
  }

subscriptions : a -> Sub Msg
subscriptions model =
  Ports.receiveAuthorizationCode (AuthenticationActions << Auth.AuthorizationCodeReceived)
