module Products.DomainTerms.Forms.Actions
  ( DomainTermFormAction(..) ) where

import Http                                  exposing (Error)
import Products.DomainTerms.DomainTerm       exposing (DomainTerm)

type DomainTermFormAction = AddDomainTerm (Result Error DomainTerm)
            | ShowDomainTermForm
            | HideDomainTermForm
            | SubmitDomainTermForm
            | SetDomainTermTitle String
            | SetDomainTermDescription String
