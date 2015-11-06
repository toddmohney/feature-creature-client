module Product where

import Html exposing (..)

-- MODEL

type alias Model = {
    id : Int
  , name : String
  , repoUrl : String
}

init : String -> String -> Model
init = Model 0

-- UPDATE (nothing here for now)

type Action = PlaceholderAction

-- VIEW

view : Model -> Html
view model = div [] [ text model.name ]
