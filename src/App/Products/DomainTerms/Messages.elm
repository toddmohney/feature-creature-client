module App.Products.DomainTerms.Messages exposing ( Msg(..) )

import App.Products.DomainTerms.DomainTerm exposing (DomainTerm)
import App.Search.Types as Search
import Http                                exposing (Error)

type Msg = DomainTermAdded DomainTerm
         | DomainTermUpdated DomainTerm
         | DomainTermCreated (Result Error DomainTerm)
         | DomainTermModified (Result Error DomainTerm)
         | SubmitDomainTermForm
         | SetDomainTermTitle String
         | SetDomainTermDescription String
         | SearchFeatures Search.Query
         | RemoveDomainTerm DomainTerm
         | DomainTermRemoved (Result Error DomainTerm)
         | ShowCreateDomainTermForm
         | ShowEditDomainTermForm DomainTerm
         | HideDomainTermForm
         | UpdateDomainTerms (Result Error (List DomainTerm))
         | FetchDomainTermsSucceeded (List DomainTerm)
         | FetchDomainTermsFailed Error
         | CreateDomainTermSucceeded DomainTerm
         | CreateDomainTermFailed Error
         | UpdateDomainTermSucceeded DomainTerm
         | UpdateDomainTermFailed Error
         | DeleteDomainTermSucceeded DomainTerm
         | DeleteDomainTermFailed Error
