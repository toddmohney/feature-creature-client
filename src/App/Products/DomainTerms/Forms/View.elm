module App.Products.DomainTerms.Forms.View exposing ( view )

import App.Products.DomainTerms.Messages   exposing (Msg(..))
import App.Products.DomainTerms.Forms.ViewModel exposing (DomainTermForm, FormMode(..))
import Data.Actions                             exposing (..)
import Html                                     exposing (Html)
import Html.Attributes                          exposing (classList, href, style)
import Html.Events                              exposing (onClick)
import UI.App.Components.Containers as UI
import UI.App.Components.Panels    as UI
import UI.App.Primitives.Forms     as UI

view : ForwardedAction Msg -> DomainTermForm -> Html Msg
view hideAction domainTermForm =
  let domainTermFormHtml = formContainer <| renderDomainTermForm hideAction domainTermForm
  in
    UI.clearfix [] [ domainTermFormHtml ]

formContainer : Html a -> Html a
formContainer content =
  Html.div
    [ classList [ ("pull-right", True) ]
    , style [ ("width", "50%") ]
    ]
    [ content ]

renderDomainTermForm : ForwardedAction Msg -> DomainTermForm -> Html Msg
renderDomainTermForm hideAction domainTermForm =
  let bodyContent    = renderForm hideAction domainTermForm
  in UI.panelWithHeading (headingContent domainTermForm.formMode) bodyContent

headingContent : FormMode -> Html a
headingContent formMode =
  case formMode of
    Create -> Html.text "Create A New Domain Term"
    Edit   -> Html.text "Edit Domain Term"

renderForm : ForwardedAction Msg -> DomainTermForm -> Html Msg
renderForm hideAction domainTermForm =
  Html.div
    []
    [ UI.input domainTermForm.titleField
    , UI.textarea domainTermForm.descriptionField
    , UI.cancelButton (onClick hideAction.action)
    , UI.submitButton (onClick SubmitDomainTermForm)
    ]
