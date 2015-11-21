module Products.Product where

import Products.DomainTerms.DomainTerm exposing (..)
import Products.Features.FeatureList   exposing (..)
import Html exposing (..)

type alias Product =
  { id          : Int
  , name        : String
  , repoUrl     : String
  , featureList : Maybe FeatureList
  , domainTerms : List DomainTerm
  }

init : String -> String -> Product
init prodName prodRepoUrl =
  { id          = 0
  , name        = prodName
  , repoUrl     = prodRepoUrl
  , featureList = Nothing
  , domainTerms = []
  }

init' : Int -> String -> String -> Product
init' prodID prodName prodRepoUrl =
  { id          = prodID
  , name        = prodName
  , repoUrl     = prodRepoUrl
  , featureList = Nothing
  , domainTerms = []
  }

view : Product -> Html
view product =
  Html.div [] [ text product.name ]
