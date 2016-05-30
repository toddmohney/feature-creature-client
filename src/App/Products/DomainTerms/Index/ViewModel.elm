module App.Products.DomainTerms.Index.ViewModel exposing
  ( DomainTermsView
  , init
  )

import App.AppConfig                                   exposing (..)
import App.Products.DomainTerms.Messages               exposing (Msg)
import App.Products.DomainTerms.Forms.ViewModel as DTF exposing (DomainTermForm)
import App.Products.DomainTerms.Requests               exposing (getDomainTerms)
import App.Products.Product                            exposing (Product)

type alias DomainTermsView =
  { product        : Product
  , domainTermForm : Maybe DomainTermForm
  }

init : Product -> AppConfig -> (DomainTermsView, Cmd Msg)
init prod appConfig =
  ( { product = prod , domainTermForm = Nothing }
  , getDomainTerms appConfig prod
  )
