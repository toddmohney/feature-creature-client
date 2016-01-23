module Data.External where

type External a = NotLoaded
                | Loaded a
                | LoadedWithError String
