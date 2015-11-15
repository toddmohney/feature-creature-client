module Product where

import Html exposing (..)

-- MODEL

type alias Product = {
    id : Int
  , name : String
  , repoUrl : String
}

init : String -> String -> Product
init = Product 0

-- UPDATE (nothing here for now)

type Action = PlaceholderAction

-- VIEW

view : Product -> Html
view product = div [] [ text product.name ]
