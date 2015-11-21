module Products.DomainTerms.DomainTerm where

import Products.Product exposing (Product)

type alias DomainTerm =
  { title : String
  , description : String
  , product : Product
  }
