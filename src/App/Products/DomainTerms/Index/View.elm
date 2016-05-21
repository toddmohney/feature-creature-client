module App.Products.DomainTerms.Index.View exposing ( view )

import App.Products.DomainTerms.DomainTerm               exposing (DomainTerm, toSearchQuery)
import App.Products.DomainTerms.Messages                 exposing (Msg(..))
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


view : DomainTermsView -> Html Msg
view domainTermsView =
  let domainTerms =
    case domainTermsView.product.domainTerms of
      Loaded dts -> dts
      _          -> []
  in
    Html.div
    []
    [ domainTermFormUI domainTermsView.domainTermForm
    , Html.div
        [ Html.classList [ ("row", True) ] ]
        (renderDomainTerms domainTerms [])
    ]

domainTermFormUI : Maybe DomainTermForm -> Html Msg
domainTermFormUI domainTermForm =
  case domainTermForm of
    Nothing ->
      createDomainTermUI
    Just domainTermForm ->
      let hideFormAction = ForwardedAction HideDomainTermForm
      in
        DTF.view hideFormAction domainTermForm

createDomainTermUI : Html Msg
createDomainTermUI =
  UI.clearfix
  [("fc-margin--bottom--medium", True)]
  [ createDomainTermButton ]

createDomainTermButton : Html Msg
createDomainTermButton =
  Html.a
  [ href "#", onClick ShowCreateDomainTermForm
  , Html.classList [ ("pull-right", True)
                   , ("btn", True)
                   , ("btn-primary", True)
                   ]
  ]
  [ Html.text "Create Domain Term" ]

renderDomainTerms : List DomainTerm -> List (Html Msg) -> List (Html Msg)
renderDomainTerms domainTerms collection =
  case domainTerms of
    []       -> collection
    x::[]    ->
      collection
        ++ [(renderDomainTerm x)]
    x::y::[] ->
      collection
        ++ [(renderDomainTerm x)]
        ++ [(renderDomainTerm y)]
        ++ [UI.colResetBlock Medium]
    x::y::z::xs ->
      renderDomainTerms xs
        <| collection
          ++ [(renderDomainTerm x)]
          ++ [(renderDomainTerm y)]
          ++ [UI.colResetBlock Medium]
          ++ [(renderDomainTerm z)]
          ++ [UI.colResetBlock Large]

renderDomainTerm : DomainTerm -> Html Msg
renderDomainTerm domainTerm =
  let searchFeaturesUI   = searchFeaturesLink domainTerm
      editDomainTermUI   = editDomainTermLink domainTerm
      removeDomainTermUI = removeDomainTermLink domainTerm
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

searchFeaturesLink : DomainTerm -> Html Msg
searchFeaturesLink domainTerm =
  let linkAction = SearchFeatures (toSearchQuery domainTerm)
  in
    Html.a
    [ href "#", onClick linkAction ]
    [ Glyph.searchIcon ]

editDomainTermLink : DomainTerm -> Html Msg
editDomainTermLink domainTerm =
  let linkAction = ShowEditDomainTermForm domainTerm
  in
    Html.a
    [ href "#", onClick linkAction ]
    [ Glyph.editIcon ]

removeDomainTermLink : DomainTerm -> Html Msg
removeDomainTermLink domainTerm =
  let linkAction = RemoveDomainTerm domainTerm
  in
    Html.a
    [ href "#", onClick linkAction ]
    [ Glyph.removeIcon ]

-- inject panelHeaderActions
domainTermPanelHeading : DomainTerm -> Html Msg -> Html Msg -> Html Msg -> Html Msg
domainTermPanelHeading domainTerm searchFeaturesLink editDomainTermLink removeDomainTermLink =
  Html.div
  [ class "clearfix" ]
  [ panelHeaderInfo domainTerm
  , panelHeaderActions searchFeaturesLink editDomainTermLink removeDomainTermLink
  ]

panelHeaderActions : Html Msg -> Html Msg -> Html Msg -> Html Msg
panelHeaderActions searchFeaturesLink editDomainTermLink removeDomainTermLink =
  Html.div
  [ class "pull-right" ]
  [ searchFeaturesLink
  , editDomainTermLink
  , removeDomainTermLink
  ]

panelHeaderInfo : DomainTerm -> Html Msg
panelHeaderInfo domainTerm =
  Html.div
  [ class "pull-left" ]
  [ Html.text domainTerm.title ]
