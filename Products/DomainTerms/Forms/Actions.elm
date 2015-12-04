module Products.DomainTerms.Forms.Actions where

import Http                                  exposing (Error)
import Products.DomainTerms.DomainTerm       exposing (DomainTerm)

type Action = AddDomainTerm (Result Error DomainTerm)
            | ShowDomainTermForm
            | HideDomainTermForm
            | SubmitDomainTermForm
            | SetDomainTermTitle String
            | SetDomainTermDescription String
