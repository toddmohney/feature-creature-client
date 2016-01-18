module Products.DomainTerms.Index.Actions where

import Http exposing (Error)
import Products.DomainTerms.DomainTerm exposing (DomainTerm)
import Products.DomainTerms.Forms.Actions as DTF
import Search.Types as Search

type DomainTermAction = UpdateDomainTerms (Result Error (List DomainTerm))
                      | SearchFeatures Search.Query
                      | DomainTermFormAction DTF.DomainTermFormAction
