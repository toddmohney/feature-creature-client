module App.Products.DomainTerms.Index.View
  ( view
  ) where

import App.Products.DomainTerms.DomainTerm               exposing (DomainTerm, toSearchQuery)
import App.Products.DomainTerms.Index.Actions as Actions exposing (DomainTermAction(..))
import App.Products.DomainTerms.Index.ViewModel          exposing (DomainTermsView)
import App.Products.DomainTerms.Forms.View    as DTF
import App.Products.DomainTerms.Forms.ViewModel          exposing (DomainTermForm)
import Data.Actions                                      exposing (..)
import Data.External                                     exposing (External(..))
import Html                                              exposing (Html)
import Html.Events                                       exposing (onClick)
import Html.Attributes as Html                           exposing (class, href)
import UI.App.Components.Containers       as UI
import UI.App.Components.Panels           as UI
import UI.Bootstrap.Components.Glyphicons as Glyph
import UI.Bootstrap.Responsiveness as UI                exposing (ScreenSize(..))


view : Signal.Address DomainTermAction -> DomainTermsView -> Html
view address domainTermsView =
  let domainTerms =
    case domainTermsView.product.domainTerms of
      Loaded dts -> dts
      _          -> []
  in
    Html.div
    []
    [ domainTermFormUI address domainTermsView.domainTermForm
    , Html.div
        [ Html.classList [ ("row", True) ] ]
        (renderDomainTerms address domainTerms [])
    ]

domainTermFormUI : Signal.Address DomainTermAction -> Maybe DomainTermForm -> Html
domainTermFormUI address domainTermForm =
  case domainTermForm of
    Nothing ->
      createDomainTermUI address
    Just domainTermForm ->
      let forwardedAddress  = Signal.forwardTo address Actions.DomainTermFormAction
          hideFormAction = ForwardedAction address Actions.HideDomainTermForm
      in
        DTF.view forwardedAddress hideFormAction domainTermForm

createDomainTermUI : Signal.Address DomainTermAction -> Html
createDomainTermUI address =
  UI.clearfix
  [("fc-margin--bottom--medium", True)]
  [ createDomainTermButton address ]

createDomainTermButton : Signal.Address DomainTermAction -> Html
createDomainTermButton address =
  Html.a
  [ href "#", onClick address Actions.ShowCreateDomainTermForm
  , Html.classList [ ("pull-right", True)
                   , ("btn", True)
                   , ("btn-primary", True)
                   ]
  ]
  [ Html.text "Create Domain Term" ]

renderDomainTerms : Signal.Address DomainTermAction -> List DomainTerm -> List Html -> List Html
renderDomainTerms address domainTerms collection =
  case domainTerms of
    []       -> collection
    x::[]    ->
      collection
        ++ [(renderDomainTerm address x)]
    x::y::[] ->
      collection
        ++ [(renderDomainTerm address x)]
        ++ [(renderDomainTerm address y)]
        ++ [UI.colResetBlock Medium]
    x::y::z::xs ->
      renderDomainTerms address xs
        <| collection
          ++ [(renderDomainTerm address x)]
          ++ [(renderDomainTerm address y)]
          ++ [UI.colResetBlock Medium]
          ++ [(renderDomainTerm address z)]
          ++ [UI.colResetBlock Large]

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
  let linkAction = ShowEditDomainTermForm domainTerm
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
