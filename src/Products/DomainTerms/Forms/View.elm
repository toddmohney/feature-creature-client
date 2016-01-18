module Products.DomainTerms.Forms.View
  ( view ) where

import Html                                  exposing (Html)
import Html.Attributes                       exposing (href)
import Html.Events                           exposing (onClick)
import Products.DomainTerms.Forms.Actions    exposing (..)
import Products.DomainTerms.Forms.ViewModel  exposing (DomainTermForm)
import UI.App.Components.Panels    as UI
import UI.App.Primitives.Forms     as UI

view : Signal.Address DomainTermFormAction -> DomainTermForm -> Html
view address domainTermForm =
  if domainTermForm.domainTermFormVisible
    then
      let domainTermFormHtml = renderDomainTermForm address domainTermForm
      in Html.div [] [ domainTermFormHtml ]
    else
      Html.a
      [ href "#", onClick address ShowDomainTermForm ]
      [ Html.text "Create Domain Term" ]

renderDomainTermForm : Signal.Address DomainTermFormAction -> DomainTermForm -> Html
renderDomainTermForm address domainTermForm =
  let headingContent = Html.text "Create A New Domain Term"
      bodyContent    = renderForm address domainTermForm
  in UI.panelWithHeading headingContent bodyContent

renderForm : Signal.Address DomainTermFormAction -> DomainTermForm -> Html
renderForm address domainTermForm =
  Html.div
    []
    [ UI.input address domainTermForm.titleField
    , UI.textarea address domainTermForm.descriptionField
    , UI.cancelButton (onClick address HideDomainTermForm)
    , UI.submitButton (onClick address SubmitDomainTermForm)
    ]
