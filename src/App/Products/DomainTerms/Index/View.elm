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
import Html.Attributes as Html                           exposing (class, href)
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
    Html.div
      [ Html.classList [ ("row", True) ] ]
      (newDomainTermForm :: (List.map (renderDomainTerm address) domainTerms))

renderDomainTerm : Signal.Address DomainTermAction -> DomainTerm -> Html
renderDomainTerm address domainTerm =
  let searchFeaturesUI   = searchFeaturesLink address domainTerm
      editDomainTermUI   = editDomainTermLink address domainTerm
      removeDomainTermUI = removeDomainTermLink address domainTerm
      responsiveClasses = Html.classList [ ("col-lg-4", True)
                                         , ("col-md-6", True)
                                         , ("col-sm-12", True)
                                         ]
  in
    Html.div
    [ responsiveClasses ]
    [ UI.panelWithHeading
        (domainTermPanelHeading domainTerm searchFeaturesUI editDomainTermUI removeDomainTermUI)
        (Html.text domainTerm.description)
    ]

searchFeaturesLink : Signal.Address DomainTermAction -> DomainTerm -> Html
searchFeaturesLink address domainTerm =
  let linkAction = SearchFeatures (toSearchQuery domainTerm)
  in
    Html.a
    [ href "#", onClick address linkAction ]
    [ Glyph.searchIcon ]

editDomainTermLink : Signal.Address DomainTermAction -> DomainTerm -> Html
editDomainTermLink address domainTerm =
  let linkAction = EditDomainTerm domainTerm
  in
    Html.a
    [ href "#", onClick address linkAction ]
    [ Glyph.editIcon ]

removeDomainTermLink : Signal.Address DomainTermAction -> DomainTerm -> Html
removeDomainTermLink address domainTerm =
  let linkAction = RemoveDomainTerm domainTerm
  in
    Html.a
    [ href "#", onClick address linkAction ]
    [ Glyph.removeIcon ]

-- inject panelHeaderActions
domainTermPanelHeading : DomainTerm -> Html -> Html -> Html -> Html
domainTermPanelHeading domainTerm searchFeaturesLink editDomainTermLink removeDomainTermLink =
  Html.div
  [ class "clearfix" ]
  [ panelHeaderInfo domainTerm
  , panelHeaderActions searchFeaturesLink editDomainTermLink removeDomainTermLink
  ]

panelHeaderActions : Html -> Html -> Html -> Html
panelHeaderActions searchFeaturesLink editDomainTermLink removeDomainTermLink =
  Html.div
  [ class "pull-right" ]
  [ searchFeaturesLink
  , editDomainTermLink
  , removeDomainTermLink
  ]

panelHeaderInfo : DomainTerm -> Html
panelHeaderInfo domainTerm =
  Html.div
  [ class "pull-left" ]
  [ Html.text domainTerm.title ]
