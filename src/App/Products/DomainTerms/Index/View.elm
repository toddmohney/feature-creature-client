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
import UI.Bootstrap.Components.Glyphicons as Glyph


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
  let searchFeaturesLink = featureLink address domainTerm
  in
    UI.panelWithHeading
      (domainTermPanelHeading domainTerm searchFeaturesLink)
      (Html.text domainTerm.description)

featureLink : Signal.Address DomainTermAction -> DomainTerm -> Html
featureLink address domainTerm =
  let linkAction = SearchFeatures (toSearchQuery domainTerm)
  in
    Html.a
    [ href "#", onClick address linkAction ]
    [ Glyph.searchIcon ]

domainTermPanelHeading : DomainTerm -> Html -> Html
domainTermPanelHeading domainTerm searchFeaturesLink =
  Html.div
  [ class "clearfix" ]
  [ panelHeaderInfo domainTerm
  , panelHeaderActions domainTerm searchFeaturesLink
  ]

panelHeaderActions : DomainTerm -> Html -> Html
panelHeaderActions domainTerm searchFeaturesLink =
  Html.div
  [ class "pull-right" ]
  [ searchFeaturesLink ]

panelHeaderInfo : DomainTerm -> Html
panelHeaderInfo domainTerm =
  Html.div
  [ class "pull-left" ]
  [ Html.text domainTerm.title ]
