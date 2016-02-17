module App.Products.Product where

import Data.External                       exposing (External(..))
import App.Products.DomainTerms.DomainTerm exposing (..)
import App.Products.Features.FeatureList   exposing (..)
import App.Products.UserRoles.UserRole     exposing (..)
import Html                                exposing (..)

type alias Product =
  { id          : Int
  , name        : String
  , repoUrl     : String
  , featureList : External FeatureList
  , domainTerms : External (List DomainTerm)
  , userRoles   : External (List UserRole)
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
  , featureList = NotLoaded
  , domainTerms = NotLoaded
  , userRoles   = NotLoaded
  }

view : Product -> Html
view product =
  Html.div [] [ text product.name ]

addUserRole : Product -> UserRole -> Product
addUserRole product userRole =
  case product.userRoles of
    Loaded urs -> { product | userRoles = Loaded (userRole :: urs) }
    _          -> { product | userRoles = Loaded [userRole] }
