module App.Products.DomainTerms.Index.ViewModel
  ( DomainTermsView
  , init
  ) where

import App.AppConfig                                   exposing (..)
import App.Products.DomainTerms.Index.Actions   as DTI exposing (DomainTermAction)
import App.Products.DomainTerms.Forms.ViewModel as DTF
import App.Products.DomainTerms.Requests               exposing (getDomainTerms)
import App.Products.Product                            exposing (Product)
import Effects                                         exposing (Effects)

type alias DomainTermsView =
  { product        : Product
  , domainTermForm : DTF.DomainTermForm
  }

init : Product -> AppConfig -> (DomainTermsView, Effects DomainTermAction)
init prod appConfig =
  let effects = getDomainTerms appConfig prod DTI.UpdateDomainTerms
  in ( { product = prod
       , domainTermForm = DTF.init prod
       }
     , effects
     )
