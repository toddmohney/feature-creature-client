module App.Products.DomainTerms.Index.Update
  ( update
  ) where

import App.AppConfig                                     exposing (..)
import App.Products.DomainTerms.Forms.Update  as DTF
import App.Products.DomainTerms.Index.Actions as Actions exposing (DomainTermAction)
import App.Products.DomainTerms.Index.ViewModel          exposing (DomainTermsView)
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
              newDomainTermForm = { domainTermForm | product = updatedProduct }
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
      let (dtForm, dtFormFx) = DTF.update dtFormAction domainTermsView.domainTermForm appConfig
          product            = domainTermsView.product
          updatedProduct     = { product | domainTerms = dtForm.product.domainTerms }
          updatedDomainTermsView = { domainTermsView |
                                     domainTermForm = dtForm
                                   , product = updatedProduct
                                   }
      in
        (,)
        updatedDomainTermsView
        (Effects.map Actions.DomainTermFormAction dtFormFx)

    Actions.SearchFeatures searchQuery -> (domainTermsView, Effects.none)
    Actions.EditDomainTerm domainTerm -> (domainTermsView, Effects.none)
    Actions.RemoveDomainTerm domainTerm -> (domainTermsView, Effects.none)

