module Products.DomainTerms.Form where

import Debug                                 exposing (crash)
import Effects                               exposing (Effects)
import Html                                  exposing (Html)
import Html.Attributes                       exposing (href)
import Html.Events                           exposing (onClick)
import Http                                  exposing (Error)
import Products.DomainTerms.DomainTerm as DT exposing (DomainTerm)
import Products.Product                      exposing (Product)
import Task                                  exposing (Task)
import UI.App.Components.Panels    as UI exposing (..)
import UI.App.Primitives.Forms     as UI exposing (..)
import Utils.Http

type alias DomainTermForm =
  { product : Product
  , domainTermFormVisible : Bool
  , newDomainTerm         : DomainTerm
  }

type Action = AddDomainTerm (Result Error DomainTerm)
            | ShowDomainTermForm
            | HideDomainTermForm
            | SubmitDomainTermForm
            | SetDomainTermTitle String
            | SetDomainTermDescription String

init : Product -> DomainTermForm
init prod =
  { product = prod
  , domainTermFormVisible = False
  , newDomainTerm = DT.init
  }

update : Action -> DomainTermForm -> (DomainTermForm, Effects Action)
update action domainTermForm =
  case action of
    AddDomainTerm domainTermResult ->
      case domainTermResult of
        Ok domainTerm ->
          let prod = domainTermForm.product
              newDomainTermsList = domainTerm :: prod.domainTerms
              updatedProduct = { prod | domainTerms <- newDomainTermsList }
              newView = { domainTermForm | product <- updatedProduct }
          in (newView, Effects.none)
        Err _ -> crash "Something went wrong!"

    ShowDomainTermForm ->
      ({ domainTermForm | domainTermFormVisible <- True }, Effects.none)

    HideDomainTermForm ->
      ({ domainTermForm | domainTermFormVisible <- False }, Effects.none)

    SetDomainTermTitle newTitle ->
      let newDomainTerm = domainTermForm.newDomainTerm
          updatedDomainTerm = { newDomainTerm | title <- newTitle }
      in ({ domainTermForm | newDomainTerm <- updatedDomainTerm }, Effects.none)

    SetDomainTermDescription newDescription ->
      let newDomainTerm = domainTermForm.newDomainTerm
          updatedDomainTerm = { newDomainTerm | description <- newDescription }
      in ({ domainTermForm | newDomainTerm <- updatedDomainTerm }, Effects.none)

    SubmitDomainTermForm ->
      ( domainTermForm
      , createDomainTerm (domainTermsUrl domainTermForm.product) domainTermForm.newDomainTerm
      )

view : Signal.Address Action -> DomainTermForm -> Html
view address domainTermForm =
  if domainTermForm.domainTermFormVisible
    then
      let domainTermFormHtml = renderDomainTermForm address
      in Html.div [] [ domainTermFormHtml ]
    else
      Html.a
      [ href "#", onClick address ShowDomainTermForm ]
      [ Html.text "Create Domain Term" ]

renderDomainTermForm : Signal.Address Action -> Html
renderDomainTermForm address =
  let headingContent = Html.text "Create A New Domain Term"
      bodyContent    = renderForm address
  in UI.panelWithHeading headingContent bodyContent

renderForm : Signal.Address Action -> Html
renderForm address =
  Html.div
    []
    [ UI.input address "domainTermTitle" (Html.text "Title") SetDomainTermTitle
    , UI.textarea address "domainTermDescription" (Html.text "Description") SetDomainTermDescription
    , UI.cancelButton (onClick address HideDomainTermForm)
    , UI.submitButton (onClick address SubmitDomainTermForm)
    ]

domainTermsUrl : Product -> String
domainTermsUrl prod = "http://localhost:8081/products/" ++ (toString prod.id) ++ "/domain-terms"

createDomainTerm : String -> DomainTerm -> Effects Action
createDomainTerm url domainTerm =
  let request = Utils.Http.jsonPostRequest url (DT.encodeDomainTerm domainTerm)
  in Http.send Http.defaultSettings request
     |> Http.fromJson DT.parseDomainTerm
     |> Task.toResult
     |> Task.map AddDomainTerm
     |> Effects.task
