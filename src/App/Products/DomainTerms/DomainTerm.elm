module App.Products.DomainTerms.DomainTerm
  ( DomainTerm
  , init
  , toSearchQuery
  ) where

import App.Search.Types as Search

type alias DomainTerm =
  { title : String
  , description : String
  }

init : DomainTerm
init = { title = ""
       , description = ""
       }

toSearchQuery : DomainTerm -> Search.Query
toSearchQuery domainTerm =
  { datatype = "DomainTerm"
  , term = domainTerm.title
  }
