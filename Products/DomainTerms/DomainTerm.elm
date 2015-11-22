module Products.DomainTerms.DomainTerm where

import UI.App.Components.Panels    as UI exposing (..)
import UI.App.Primitives.Forms     as UI exposing (..)
import Html exposing (..)
import Html.Events exposing (onClick)

type alias DomainTerm =
  { title : String
  , description : String
  }

type Action = HideDomainTermForm
            | SubmitDomainTermForm

form : Signal.Address Action -> Html
form address =
  let headingContent = text "Create A New Domain Term"
      bodyContent    = renderForm address
  in UI.panelWithHeading headingContent bodyContent

renderForm : Signal.Address Action -> Html
renderForm address =
  Html.form
    []
    [ UI.input "domainTermTitle" (text "Title")
    , UI.input "domainTermDescription" (text "Description")
    , UI.cancelButton (onClick address HideDomainTermForm)
    , UI.submitButton (onClick address SubmitDomainTermForm)
    ]
