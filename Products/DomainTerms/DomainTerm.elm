module Products.DomainTerms.DomainTerm where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Style exposing (..)

type alias DomainTerm =
  { title : String
  , description : String
  }

type Action = HideDomainTermForm
            | SubmitDomainTermForm

form : Signal.Address Action -> Html
form address=
  Html.div
    [ panelDefault ]
    [
      Html.div
        [ panelHeading ]
        [
          Html.h3
            [ panelTitle ]
            [ text "Create A New Domain Term" ]
        ]
    , Html.div
        [ panelBody ]
        [ renderForm address ]
    ]

renderForm : Signal.Address Action -> Html
renderForm address =
  Html.form
    []
    [
      Html.div
        [ class "form-group" ]
        [
          Html.label
            [ for "domainTermTitle" ]
            [ text "Title" ]
        , Html.input
            [ class "form-control"
            , id "domainTermTitle"
            , name "domainTermTitle"
            ]
            []
        ]
    , Html.div
        [ class "form-group" ]
        [ Html.label
            [ for "domainTermDescription" ]
            [ text "Description" ]
        , Html.textarea
            [ class "form-control"
            , id "domainTermDescription"
            , name "domainTermDescription"
            ]
            []
        ]
    , Html.button
        [ btn, onClick address HideDomainTermForm ]
        [ text "Cancel" ]
    , Html.button
        [ primaryBtn, onClick address SubmitDomainTermForm ]
        [ text "Submit" ]
    ]
