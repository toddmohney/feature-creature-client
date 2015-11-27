module Products.DomainTerms.DomainTermsView where

import Debug                                 exposing (crash)
import Effects                               exposing (Effects)
import Html                                  exposing (Html)
import Http                                  exposing (Error)
import Products.DomainTerms.DomainTerm as DT exposing (DomainTerm)
import Products.DomainTerms.Form as DTF
import Products.Product                      exposing (Product)
import Task                                  exposing (Task)
import UI.App.Components.Panels as UI

type alias DomainTermsView =
  { product        : Product
  , domainTermForm : DTF.DomainTermForm
  }

type Action = UpdateDomainTerms (Result Error (List DomainTerm))
            | DomainTermFormAction DTF.Action

init : Product -> (DomainTermsView, Effects Action)
init prod =
  let effects = getDomainTermsList (domainTermsUrl prod)
  in ( { product = prod
       , domainTermForm = DTF.init prod
       }
     , effects
     )

update : Action -> DomainTermsView -> (DomainTermsView, Effects Action)
update action domainTermsView =
  case action of
    -- This is smelly. The DomainTermFrom is allowed to update the Product,
    -- so we need to update both this model and the form model.
    -- Try to refactor to let the updates flow in One Direction
    UpdateDomainTerms domainTermsResult ->
      case domainTermsResult of
        Ok domainTermList ->
          let prod = domainTermsView.product
              updatedProduct = { prod | domainTerms = domainTermList }
              domainTermForm = domainTermsView.domainTermForm
              newDomainTermForm = { domainTermForm | product = updatedProduct }
              newView = { domainTermsView |
                          product = updatedProduct
                        , domainTermForm = newDomainTermForm
                        }
          in (newView, Effects.none)
        Err _ -> crash "Something went wrong!"

    -- This is smelly. The DomainTermFrom is allowed to update the Product,
    -- so we need to update both this model and the form model.
    -- Try to refactor to let the updates flow in One Direction
    DomainTermFormAction dtFormAction ->
      let (dtForm, dtFormFx) = DTF.update dtFormAction domainTermsView.domainTermForm
          prod = domainTermsView.product
          updatedProduct = { prod | domainTerms = dtForm.product.domainTerms }
          updatedDomainTermsView = { domainTermsView |
                                     domainTermForm = dtForm
                                   , product = updatedProduct
                                   }
      in ( updatedDomainTermsView
         , Effects.map DomainTermFormAction dtFormFx
         )

view : Signal.Address Action -> DomainTermsView -> Html
view address domainTermsView =
  let domainTerms = domainTermsView.product.domainTerms
      forwardedAddress = (Signal.forwardTo address DomainTermFormAction)
      newDomainTermForm = DTF.view forwardedAddress domainTermsView.domainTermForm
  in Html.div [] (newDomainTermForm :: (List.map (renderDomainTerm address) domainTerms))

getDomainTermsList : String -> Effects Action
getDomainTermsList url =
  Http.get DT.parseDomainTerms url
   |> Task.toResult
   |> Task.map UpdateDomainTerms
   |> Effects.task

renderDomainTerm : Signal.Address Action -> DomainTerm -> Html
renderDomainTerm address domainTerm =
  UI.panelWithHeading (Html.text domainTerm.title) (Html.text domainTerm.description)

domainTermsUrl : Product -> String
domainTermsUrl prod = "http://localhost:8081/products/" ++ (toString prod.id) ++ "/domain-terms"
