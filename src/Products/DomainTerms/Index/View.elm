module Products.DomainTerms.Index.View
  ( view
  ) where

import Html                                          exposing (Html)
import Html.Events                                   exposing (onClick)
import Html.Attributes                               exposing (class, href)
import Products.DomainTerms.DomainTerm               exposing (DomainTerm, toSearchQuery)
import Products.DomainTerms.Index.Actions as Actions exposing (DomainTermAction(..))
import Products.DomainTerms.Index.ViewModel          exposing (DomainTermsView)
import Products.DomainTerms.Forms.View    as DTF
import UI.App.Components.Panels           as UI


view : Signal.Address DomainTermAction -> DomainTermsView -> Html
view address domainTermsView =
  let domainTerms       = domainTermsView.product.domainTerms
      forwardedAddress  = Signal.forwardTo address Actions.DomainTermFormAction
      newDomainTermForm = DTF.view forwardedAddress domainTermsView.domainTermForm
  in Html.div [] (newDomainTermForm :: (List.map (renderDomainTerm address) domainTerms))

renderDomainTerm : Signal.Address DomainTermAction -> DomainTerm -> Html
renderDomainTerm address domainTerm =
  let domainTermName = Html.div [ class "pull-left" ] [ Html.text domainTerm.title ]
      linkAction     = SearchFeatures (toSearchQuery domainTerm)
      featureLink    = Html.a [ href "#", onClick address linkAction ] [ Html.text "View features" ]
      featureLinkContainer = Html.div [ class "pull-right" ] [ featureLink ]
      headingContent = Html.div [ class "clearfix" ] [ domainTermName, featureLinkContainer ]
  in UI.panelWithHeading headingContent (Html.text domainTerm.description)
