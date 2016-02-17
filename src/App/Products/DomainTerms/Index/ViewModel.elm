module App.Products.DomainTerms.Index.ViewModel
  ( DomainTermsView
  , init
  ) where

import App.AppConfig                                   exposing (..)
import App.Products.DomainTerms.Index.Actions   as DTI exposing (DomainTermAction)
import App.Products.DomainTerms.Forms.ViewModel as DTF exposing (DomainTermForm)
import App.Products.DomainTerms.Requests               exposing (getDomainTerms)
import App.Products.Product                            exposing (Product)
import Effects                                         exposing (Effects)

type alias DomainTermsView =
  { product        : Product
  , domainTermForm : Maybe DomainTermForm
  }

init : Product -> AppConfig -> (DomainTermsView, Effects DomainTermAction)
init prod appConfig =
  ( { product = prod , domainTermForm = Nothing }
  , getDomainTerms appConfig prod DTI.UpdateDomainTerms
  )
