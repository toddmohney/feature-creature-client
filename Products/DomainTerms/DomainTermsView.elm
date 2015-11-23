module Products.DomainTerms.DomainTermsView where

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

type alias DomainTermsView =
  { product               : Product
  , domainTermFormVisible : Bool
  , newDomainTerm         : DomainTerm
  }

type Action = AddDomainTerm (Result Error DomainTerm)
            | UpdateDomainTerms (Result Error (List DomainTerm))
            | ShowDomainTermForm
            | HideDomainTermForm
            | SubmitDomainTermForm
            | SetDomainTermTitle String
            | SetDomainTermDescription String


init : Product -> (DomainTermsView, Effects Action)
init prod =
  let effects = getDomainTermsList (domainTermsUrl prod)
  in ( { product               = prod
       , domainTermFormVisible = False
       , newDomainTerm         = DT.init
       }
     , effects
     )

update : Action -> DomainTermsView -> (DomainTermsView, Effects Action)
update action domainTermsView =
  case action of
    AddDomainTerm domainTermResult ->
      case domainTermResult of
        Ok domainTerm ->
          let prod = domainTermsView.product
              newDomainTermsList = domainTerm :: prod.domainTerms
              updatedProduct = { prod | domainTerms <- newDomainTermsList }
              newView = { domainTermsView | product <- updatedProduct }
          in (newView, Effects.none)
        Err _ -> crash "Something went wrong!"

    UpdateDomainTerms domainTermsResult ->
      case domainTermsResult of
        Ok domainTermList ->
          let prod = domainTermsView.product
              updatedProduct = { prod | domainTerms <- domainTermList }
              newView = { domainTermsView | product <- updatedProduct }
          in (newView, Effects.none)
        Err _ -> crash "Something went wrong!"

    ShowDomainTermForm ->
      ({ domainTermsView | domainTermFormVisible <- True }, Effects.none)

    HideDomainTermForm ->
      ({ domainTermsView | domainTermFormVisible <- False }, Effects.none)

    SetDomainTermTitle newTitle ->
      let newDomainTerm = domainTermsView.newDomainTerm
          updatedDomainTerm = { newDomainTerm | title <- newTitle }
      in ({ domainTermsView | newDomainTerm <- updatedDomainTerm }, Effects.none)

    SetDomainTermDescription newDescription ->
      let newDomainTerm = domainTermsView.newDomainTerm
          updatedDomainTerm = { newDomainTerm | description <- newDescription }
      in ({ domainTermsView | newDomainTerm <- updatedDomainTerm }, Effects.none)

    SubmitDomainTermForm ->
      ( domainTermsView
      , createDomainTerm (domainTermsUrl domainTermsView.product) domainTermsView.newDomainTerm
      )

view : Signal.Address Action -> DomainTermsView -> Html
view address domainTermsView =
  let domainTerms = domainTermsView.product.domainTerms
      newDomainTermForm = showDomainTermForm address domainTermsView
  in Html.div [] (newDomainTermForm :: (List.map (renderDomainTerm address) domainTerms))

domainTermsUrl : Product -> String
domainTermsUrl prod = "http://localhost:8081/products/" ++ (toString prod.id) ++ "/domain-terms"

getDomainTermsList : String -> Effects Action
getDomainTermsList url =
  Http.get DT.parseDomainTerms url
   |> Task.toResult
   |> Task.map UpdateDomainTerms
   |> Effects.task

createDomainTerm : String -> DomainTerm -> Effects Action
createDomainTerm url domainTerm =
  let request = Utils.Http.jsonPostRequest url (DT.encodeDomainTerm domainTerm)
  in Http.send Http.defaultSettings request
     |> Http.fromJson DT.parseDomainTerm
     |> Task.toResult
     |> Task.map AddDomainTerm
     |> Effects.task

renderDomainTerm : Signal.Address Action -> DomainTerm -> Html
renderDomainTerm address domainTerm =
  panelWithHeading (Html.text domainTerm.title) (Html.text domainTerm.description)

showDomainTermForm : Signal.Address Action -> DomainTermsView -> Html
showDomainTermForm address domainTermsView =
  if domainTermsView.domainTermFormVisible
    then
      let domainTermFormHtml = domainTermForm address
      in Html.div [] [ domainTermFormHtml ]
    else
      Html.a
      [ href "#", onClick address ShowDomainTermForm ]
      [ Html.text "Create Domain Term" ]

domainTermForm : Signal.Address Action -> Html
domainTermForm address =
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

