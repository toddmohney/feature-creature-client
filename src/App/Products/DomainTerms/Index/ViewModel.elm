module App.Products.DomainTerms.Index.ViewModel
  ( DomainTermsView
  , init
  ) where

import App.Products.DomainTerms.DomainTerm as DT
import App.Products.DomainTerms.Index.Actions as DTI exposing (DomainTermAction)
import App.Products.DomainTerms.Forms.ViewModel as DTF
import App.Products.Product                          exposing (Product)
import Effects                                   exposing (Effects)
import Http
import Task                                      exposing (Task)

type alias DomainTermsView =
  { product        : Product
  , domainTermForm : DTF.DomainTermForm
  }

init : Product -> (DomainTermsView, Effects DomainTermAction)
init prod =
  let effects = getDomainTermsList (domainTermsUrl prod)
  in ( { product = prod
       , domainTermForm = DTF.init prod
       }
     , effects
     )

getDomainTermsList : String -> Effects DomainTermAction
getDomainTermsList url =
  Http.get DT.parseDomainTerms url
   |> Task.toResult
   |> Task.map DTI.UpdateDomainTerms
   |> Effects.task

domainTermsUrl : Product -> String
domainTermsUrl prod = "http://localhost:8081/products/" ++ (toString prod.id) ++ "/domain-terms"
