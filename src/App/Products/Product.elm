module App.Products.Product exposing (..)

import Data.External                       exposing (External(..))
import App.Products.DomainTerms.DomainTerm exposing (..)
import App.Products.Features.FeatureList   exposing (..)
import App.Products.UserRoles.UserRole     exposing (..)
import Html                                exposing (..)

type alias Product =
  { id          : Int
  , name        : String
  , repoUrl     : String
  , repoState   : RepositoryState
  , repoError   : Maybe String
  , featureList : External FeatureList
  , domainTerms : External (List DomainTerm)
  , userRoles   : External (List UserRole)
  }

type RepositoryState = Unready
                     | Ready
                     | Error

newProduct : Product
newProduct = init "" ""

init : String -> String -> Product
init prodName prodRepoUrl = init' 0 prodName prodRepoUrl Unready Nothing

init' : Int -> String -> String -> RepositoryState -> Maybe String -> Product
init' prodID prodName prodRepoUrl prodRepoState prodRepoError =
  { id          = prodID
  , name        = prodName
  , repoUrl     = prodRepoUrl
  , repoState   = prodRepoState
  , repoError   = prodRepoError
  , featureList = NotLoaded
  , domainTerms = NotLoaded
  , userRoles   = NotLoaded
  }

view : Product -> Html
view product =
  Html.div [] [ text product.name ]
