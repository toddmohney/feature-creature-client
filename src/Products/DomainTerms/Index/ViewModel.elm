module Products.DomainTerms.Index.ViewModel
  ( DomainTermsView
  , init
  ) where

import Effects                                   exposing (Effects)
import Http
import Products.DomainTerms.DomainTerm as DT
import Products.DomainTerms.Index.Actions as DTI exposing (Action)
import Products.DomainTerms.Forms.ViewModel as DTF
import Products.Product                          exposing (Product)
import Task                                      exposing (Task)

type alias DomainTermsView =
  { product        : Product
  , domainTermForm : DTF.DomainTermForm
  }

init : Product -> (DomainTermsView, Effects Action)
init prod =
  let effects = getDomainTermsList (domainTermsUrl prod)
  in ( { product = prod
       , domainTermForm = DTF.init prod
       }
     , effects
     )

getDomainTermsList : String -> Effects Action
getDomainTermsList url =
  Http.get DT.parseDomainTerms url
   |> Task.toResult
   |> Task.map DTI.UpdateDomainTerms
   |> Effects.task

domainTermsUrl : Product -> String
domainTermsUrl prod = "http://localhost:8081/products/" ++ (toString prod.id) ++ "/domain-terms"
