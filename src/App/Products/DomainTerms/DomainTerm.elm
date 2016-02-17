module App.Products.DomainTerms.DomainTerm
  ( DomainTerm
  , init
  , toSearchQuery
  ) where

import App.Search.Types as Search

type alias DomainTerm =
  { id          : Maybe Int
  , title       : String
  , description : String
  }

init : DomainTerm
init = init' Nothing

init' : Maybe Int -> DomainTerm
init' domainTermID =
  { id          = domainTermID
  , title       = ""
  , description = ""
  }

toSearchQuery : DomainTerm -> Search.Query
toSearchQuery domainTerm =
  { datatype = "DomainTerm"
  , term     = domainTerm.title
  }
