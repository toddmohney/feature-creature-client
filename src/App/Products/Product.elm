module App.Products.Product where

import Json.Encode
import Json.Decode as Json                 exposing ((:=))
import App.Products.DomainTerms.DomainTerm exposing (..)
import App.Products.Features.FeatureList   exposing (..)
import App.Products.UserRoles.UserRole     exposing (..)
import Html                                exposing (..)

type alias Product =
  { id          : Int
  , name        : String
  , repoUrl     : String
  , featureList : Maybe FeatureList
  , domainTerms : List DomainTerm
  , userRoles   : List UserRole
  }

newProduct : Product
newProduct = init "" ""

init : String -> String -> Product
init prodName prodRepoUrl = init' 0 prodName prodRepoUrl

init' : Int -> String -> String -> Product
init' prodID prodName prodRepoUrl =
  { id          = prodID
  , name        = prodName
  , repoUrl     = prodRepoUrl
  , featureList = Nothing
  , domainTerms = []
  , userRoles   = []
  }

view : Product -> Html
view product =
  Html.div [] [ text product.name ]

parseProducts : Json.Decoder (List Product)
parseProducts = parseProduct |> Json.list

parseProduct : Json.Decoder Product
parseProduct =
  Json.object3
    init'
    ("id"      := Json.int)
    ("name"    := Json.string)
    ("repoUrl" := Json.string)

encodeProduct : Product -> String
encodeProduct product =
  Json.Encode.encode 0
    <| Json.Encode.object
        [ ("name",    Json.Encode.string product.name)
        , ("repoUrl", Json.Encode.string product.repoUrl)
        ]
