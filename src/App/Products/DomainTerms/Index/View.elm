module App.Products.DomainTerms.Index.View
  ( view
  ) where

import App.Products.DomainTerms.DomainTerm               exposing (DomainTerm, toSearchQuery)
import App.Products.DomainTerms.Index.Actions as Actions exposing (DomainTermAction(..))
import App.Products.DomainTerms.Index.ViewModel          exposing (DomainTermsView)
import App.Products.DomainTerms.Forms.View    as DTF
import Data.External                                     exposing (External(..))
import Html                                              exposing (Html)
import Html.Events                                       exposing (onClick)
import Html.Attributes                                   exposing (class, href)
import UI.App.Components.Panels           as UI


view : Signal.Address DomainTermAction -> DomainTermsView -> Html
view address domainTermsView =
  let forwardedAddress  = Signal.forwardTo address Actions.DomainTermFormAction
      newDomainTermForm = DTF.view forwardedAddress domainTermsView.domainTermForm
      domainTerms       = case domainTermsView.product.domainTerms of
                            Loaded dts -> dts
                            _          -> []
  in
    Html.div [] (newDomainTermForm :: (List.map (renderDomainTerm address) domainTerms))

renderDomainTerm : Signal.Address DomainTermAction -> DomainTerm -> Html
renderDomainTerm address domainTerm =
  UI.panelWithHeading
    (domainTermPanelHeading address domainTerm)
    (Html.text domainTerm.description)

domainTermPanelHeading : Signal.Address DomainTermAction -> DomainTerm -> Html
domainTermPanelHeading address domainTerm =
  Html.div
  [ class "clearfix" ]
  [ panelHeaderInfo domainTerm
  , panelHeaderActions address domainTerm
  ]

panelHeaderActions : Signal.Address DomainTermAction -> DomainTerm -> Html
panelHeaderActions address domainTerm =
  Html.div
  [ class "pull-right" ]
  [ featureLink address domainTerm ]

featureLink : Signal.Address DomainTermAction -> DomainTerm -> Html
featureLink address domainTerm =
  let linkAction     = SearchFeatures (toSearchQuery domainTerm)
  in
    Html.a
    [ href "#", onClick address linkAction ]
    [ Html.text "View features" ]

panelHeaderInfo : DomainTerm -> Html
panelHeaderInfo domainTerm =
  Html.div
  [ class "pull-left" ]
  [ Html.text domainTerm.title ]
