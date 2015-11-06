module Main where

import Task     exposing (Task)
import Effects  exposing (Never)

import App      as App exposing (update, init, view)
import StartApp as SA  exposing (start)


app = SA.start
  { init   = App.init
  , update = App.update
  , view   = App.view
  , inputs = []
  }

main = app.html

port tasks : Signal (Task.Task Never ())
port tasks = app.tasks
