module App.Products.DomainTerms.Index.Update
  ( update
  ) where

import App.AppConfig                                     exposing (..)
import App.Products.DomainTerms.DomainTerm    as DT
import App.Products.DomainTerms.Forms.ViewModel as DTF
import App.Products.DomainTerms.Forms.Update  as DTF
import App.Products.DomainTerms.Index.Actions as Actions exposing (DomainTermAction)
import App.Products.DomainTerms.Index.ViewModel          exposing (DomainTermsView)
import App.Products.DomainTerms.Requests                 exposing (getDomainTerms, removeDomainTerm)
import CoreExtensions.Maybe as Maybe
import Data.External                                     exposing (External(..))
import Debug                                             exposing (crash, log)
import Effects                                           exposing (Effects)

update : DomainTermAction -> DomainTermsView -> AppConfig -> (DomainTermsView, Effects DomainTermAction)
update action domainTermsView appConfig =
  case action of
    -- This is smelly. The DomainTermForm is allowed to update the Product,
    -- so we need to update both this model and the form model.
    -- Try to refactor to let the updates flow in One Direction
    Actions.UpdateDomainTerms domainTermsResult ->
      case domainTermsResult of
        Ok domainTermList ->
          let product           = domainTermsView.product
              domainTermForm    = domainTermsView.domainTermForm
              updatedProduct    = { product | domainTerms = Loaded domainTermList }
              newDomainTermForm = Maybe.map2 DTF.setProduct domainTermForm (Just updatedProduct)
              newView = { domainTermsView |
                          product = updatedProduct
                        , domainTermForm = newDomainTermForm
                        }
          in (newView, Effects.none)
        Err _ ->
          crash "Something went wrong!"

    -- This is smelly. The DomainTermForm is allowed to update the Product,
    -- so we need to update both this model and the form model.
    -- Try to refactor to let the updates flow in One Direction
    Actions.DomainTermFormAction dtFormAction ->
      let (dtForm, dtFormFx) = DTF.update dtFormAction (Maybe.fromJust domainTermsView.domainTermForm) appConfig
          product            = dtForm.product
          updatedProduct     = { product | domainTerms = product.domainTerms }
          updatedDomainTermsView = { domainTermsView |
                                     domainTermForm = Just dtForm
                                   , product = updatedProduct
                                   }
      in
        (,)
        updatedDomainTermsView
        (Effects.map Actions.DomainTermFormAction dtFormFx)

    Actions.SearchFeatures searchQuery -> (domainTermsView, Effects.none)

    Actions.RemoveDomainTerm domainTerm ->
      (,)
      domainTermsView
      (removeDomainTerm appConfig domainTermsView.product domainTerm Actions.DomainTermRemoved)

    Actions.DomainTermRemoved result ->
      -- This always results in an error, even with a 200 response
      -- because Elm cannot parse an empty response body.
      -- We can make this better, however.
      -- see: https://github.com/evancz/elm-http/issues/5
      case result of
        Ok a ->
          (,)
          domainTermsView
          (getDomainTerms appConfig domainTermsView.product Actions.UpdateDomainTerms)
        Err err ->
          (,)
          domainTermsView
          (getDomainTerms appConfig domainTermsView.product Actions.UpdateDomainTerms)

    Actions.ShowCreateDomainTermForm ->
      let product = domainTermsView.product
          newForm = DTF.init product DT.init
      in
        ({ domainTermsView | domainTermForm = Just newForm }, Effects.none)

    Actions.ShowEditDomainTermForm domainTerm ->
      let product = domainTermsView.product
          newForm = DTF.init product domainTerm
      in
        ({ domainTermsView | domainTermForm = Just newForm }, Effects.none)

    Actions.HideDomainTermForm ->
      ({ domainTermsView | domainTermForm = Nothing }, Effects.none)

