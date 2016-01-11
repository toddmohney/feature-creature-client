module Products.DomainTerms.Index.View
  ( view
  ) where

import Html                                          exposing (Html)
import Html.Attributes                               exposing (class)
import Products.DomainTerms.DomainTerm               exposing (DomainTerm)
import Products.DomainTerms.Index.Actions as Actions exposing (Action)
import Products.DomainTerms.Index.Model              exposing (DomainTermsView)
import Products.DomainTerms.Forms.View    as DTF
import UI.App.Components.Panels           as UI


view : Signal.Address Action -> DomainTermsView -> Html
view address domainTermsView =
  let domainTerms       = domainTermsView.product.domainTerms
      forwardedAddress  = Signal.forwardTo address Actions.DomainTermFormAction
      newDomainTermForm = DTF.view forwardedAddress domainTermsView.domainTermForm
  in Html.div [] (newDomainTermForm :: (List.map (renderDomainTerm address) domainTerms))

renderDomainTerm : Signal.Address Action -> DomainTerm -> Html
renderDomainTerm address domainTerm =
  let domainTermName = Html.div [ class "pull-left" ] [ Html.text domainTerm.title ]
      featureLink    = Html.div [ class "pull-right" ] [ Html.a [] [ Html.text "View features" ] ]
      headingContent = Html.div [ class "clearfix" ] [ domainTermName, featureLink ]
  in UI.panelWithHeading headingContent (Html.text domainTerm.description)
