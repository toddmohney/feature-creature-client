module App.Products.DomainTerms.Forms.View
  ( view ) where

import App.Products.DomainTerms.Forms.Actions   exposing (..)
import App.Products.DomainTerms.Forms.ViewModel exposing (DomainTermForm, FormMode(..))
import Data.Actions                             exposing (..)
import Html                                     exposing (Html)
import Html.Attributes                          exposing (classList, href, style)
import Html.Events                              exposing (onClick)
import UI.App.Components.Containers as UI
import UI.App.Components.Panels    as UI
import UI.App.Primitives.Forms     as UI


view : Signal.Address DomainTermFormAction -> ForwardedAction a -> DomainTermForm -> Html
view address hideAction domainTermForm =
  let domainTermFormHtml = domainTermFormContainer <| renderDomainTermForm address hideAction domainTermForm
  in
    UI.clearfix [] [ domainTermFormHtml ]

domainTermFormContainer : Html -> Html
domainTermFormContainer content =
  Html.div
    [ classList [ ("pull-right", True) ]
    , style [ ("width", "50%") ]
    ]
    [ content ]

renderDomainTermForm : Signal.Address DomainTermFormAction -> ForwardedAction a -> DomainTermForm -> Html
renderDomainTermForm address hideAction domainTermForm =
  let bodyContent    = renderForm address hideAction domainTermForm
  in UI.panelWithHeading (headingContent domainTermForm.formMode) bodyContent

headingContent : FormMode -> Html
headingContent formMode =
  case formMode of
    Create -> Html.text "Create A New Domain Term"
    Edit   -> Html.text "Edit Domain Term"

renderForm : Signal.Address DomainTermFormAction -> ForwardedAction a -> DomainTermForm -> Html
renderForm address hideAction domainTermForm =
  Html.div
    []
    [ UI.input address domainTermForm.titleField
    , UI.textarea address domainTermForm.descriptionField
    , UI.cancelButton (onClick hideAction.address hideAction.action)
    , UI.submitButton (onClick address SubmitDomainTermForm)
    ]
