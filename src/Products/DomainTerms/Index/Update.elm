module Products.DomainTerms.Index.Update
  ( update
  ) where

import Debug                                         exposing (crash, log)
import Effects                                       exposing (Effects)
import Products.DomainTerms.Forms.Update  as DTF
import Products.DomainTerms.Index.Actions as Actions exposing (Action)
import Products.DomainTerms.Index.ViewModel              exposing (DomainTermsView)

update : Action -> DomainTermsView -> (DomainTermsView, Effects Action)
update action domainTermsView =
  case action of
    -- This is smelly. The DomainTermForm is allowed to update the Product,
    -- so we need to update both this model and the form model.
    -- Try to refactor to let the updates flow in One Direction
    Actions.UpdateDomainTerms domainTermsResult ->
      case domainTermsResult of
        Ok domainTermList ->
          let prod              = domainTermsView.product
              updatedProduct    = { prod | domainTerms = domainTermList }
              domainTermForm    = domainTermsView.domainTermForm
              newDomainTermForm = { domainTermForm | product = updatedProduct }
              newView = { domainTermsView |
                          product = updatedProduct
                        , domainTermForm = newDomainTermForm
                        }
          in (newView, Effects.none)
        Err _ -> crash "Something went wrong!"

    -- This is smelly. The DomainTermForm is allowed to update the Product,
    -- so we need to update both this model and the form model.
    -- Try to refactor to let the updates flow in One Direction
    Actions.DomainTermFormAction dtFormAction ->
      let (dtForm, dtFormFx) = DTF.update dtFormAction domainTermsView.domainTermForm
          prod               = domainTermsView.product
          updatedProduct     = { prod | domainTerms = dtForm.product.domainTerms }
          updatedDomainTermsView = { domainTermsView |
                                     domainTermForm = dtForm
                                   , product = updatedProduct
                                   }
      in ( updatedDomainTermsView
         , Effects.map Actions.DomainTermFormAction dtFormFx
         )

    Actions.SearchFeatures searchQuery ->
      -- noop
      (domainTermsView, Effects.none)

