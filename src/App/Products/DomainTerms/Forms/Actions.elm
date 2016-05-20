module App.Products.DomainTerms.Forms.Actions exposing ( DomainTermFormAction(..) )

import App.Products.DomainTerms.DomainTerm exposing (DomainTerm)
import Http                                exposing (Error)

type DomainTermFormAction = DomainTermAdded DomainTerm
                          | DomainTermUpdated DomainTerm
                          | DomainTermCreated (Result Error DomainTerm)
                          | DomainTermModified (Result Error DomainTerm)
                          | SubmitDomainTermForm
                          | SetDomainTermTitle String
                          | SetDomainTermDescription String
