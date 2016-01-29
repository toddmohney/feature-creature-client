module Main where

import App.Actions as App
import App.App  as App
import App.Update  as App
import App.AppConfig      exposing (..)
import Effects            exposing (Never)
import Html               exposing (Html)
import UI.SyntaxHighlighting exposing (highlightSyntaxMailbox)
import StartApp as SA     exposing (start)
import Task               exposing (Task)


app : SA.App App.App
app = SA.start
  { init   = App.init
  , update = App.update
  , view   = App.view
  , inputs = [(Signal.map App.ConfigLoaded initAppConfig)]
  }

main : Signal Html.Html
main = app.html

port tasks : Signal (Task.Task Never ())
port tasks = app.tasks

port initAppConfig : Signal AppConfig

port highlightSyntaxPort : Signal (Maybe ())
port highlightSyntaxPort = highlightSyntaxMailbox.signal
