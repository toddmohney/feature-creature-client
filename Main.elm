module Main where

import App      as App exposing (update, init, view)
import Effects         exposing (Never)
import Html            exposing (Html)
import StartApp as SA  exposing (start)
import Task            exposing (Task)


app : SA.App App.App
app = SA.start
  { init   = App.init
  , update = App.update
  , view   = App.view
  , inputs = []
  }

main : Signal Html.Html
main = app.html

port tasks : Signal (Task.Task Never ())
port tasks = app.tasks
