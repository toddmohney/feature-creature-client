module App.Products.DomainTerms.Forms.View
  ( view ) where

import App.Products.DomainTerms.Forms.Actions   exposing (..)
import App.Products.DomainTerms.Forms.ViewModel exposing (DomainTermForm)
import Html                                     exposing (Html)
import Html.Attributes                          exposing (classList, href, style)
import Html.Events                              exposing (onClick)
import UI.App.Components.Panels    as UI
import UI.App.Primitives.Forms     as UI

view : Signal.Address DomainTermFormAction -> DomainTermForm -> Html
view address domainTermForm =
  case domainTermForm.domainTermFormVisible of
    True ->
      let domainTermFormHtml = renderDomainTermForm address domainTermForm
      in
        Html.div
        [ classList [ ("clearfix", True) ] ]
        [ Html.div
          [ classList [ ("pull-right", True) ]
          , style [ ("width", "50%") ]
          ]
          [ domainTermFormHtml ]
        ]
    False ->
      Html.div
      [ classList [ ("clearfix", True), ("fc-margin--bottom--medium", True) ] ]
      [ renderFormButton address ]

renderFormButton : Signal.Address DomainTermFormAction -> Html
renderFormButton address =
  Html.a
  [ href "#", onClick address ShowDomainTermForm
  , classList [ ("pull-right", True)
              , ("btn", True)
              , ("btn-primary", True)
              ]
  ]
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
