module Data.External exposing (..)

type External a = NotLoaded
                | Loaded a
                | LoadedWithError String
