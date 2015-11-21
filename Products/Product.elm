module Products.Product where

import Html exposing (..)

type alias Product = {
    id : Int
  , name : String
  , repoUrl : String
}

init : String -> String -> Product
init = Product 0

view : Product -> Html
view product =
  Html.div
    []
    [ text product.name ]
