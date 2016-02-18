module App.Products.DomainTerms.Index.Actions where

import App.Products.DomainTerms.DomainTerm exposing (DomainTerm)
import App.Products.DomainTerms.Forms.Actions as DTF
import App.Search.Types as Search
import Http exposing (Error)

type DomainTermAction = UpdateDomainTerms (Result Error (List DomainTerm))
                      | SearchFeatures Search.Query
                      | RemoveDomainTerm DomainTerm
                      | DomainTermRemoved (Result Error DomainTerm)
                      | DomainTermFormAction DTF.DomainTermFormAction
                      | ShowCreateDomainTermForm
                      | ShowEditDomainTermForm DomainTerm
                      | HideDomainTermForm
