module Products.DomainTerms.DomainTerm where

type alias DomainTerm =
  { title : String
  , description : String
  }

init : DomainTerm
init = { title = ""
       , description = ""
       }
