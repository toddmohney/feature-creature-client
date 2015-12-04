module Products.DomainTerms.Form where

import CoreExtensions.Either                 exposing (..)
import Debug                                 exposing (crash)
import Effects                               exposing (Effects)
import Html                                  exposing (Html)
import Html.Attributes                       exposing (href)
import Html.Events                           exposing (onClick)
import Http                                  exposing (Error)
import Products.DomainTerms.DomainTerm as DT exposing (DomainTerm)
import Products.Product                      exposing (Product)
import String                                exposing (isEmpty)
import Task                                  exposing (Task)
import UI.App.Components.Panels    as UI exposing (..)
import UI.App.Primitives.Forms     as UI exposing (..)
import Utils.Http

type alias DomainTermForm =
  { product : Product
  , domainTermFormVisible : Bool
  , newDomainTerm         : DomainTerm
  , formState             : FormState
  }

type Action = AddDomainTerm (Result Error DomainTerm)
            | ShowDomainTermForm
            | HideDomainTermForm
            | SubmitDomainTermForm
            | SetDomainTermTitle String
            | SetDomainTermDescription String

type FormState = InitialState
               | HasError
               | Valid

init : Product -> DomainTermForm
init prod =
  { product = prod
  , domainTermFormVisible = False
  , newDomainTerm = DT.init
  , formState = InitialState
  }

update : Action -> DomainTermForm -> (DomainTermForm, Effects Action)
update action domainTermForm =
  case action of
    AddDomainTerm domainTermResult ->
      case domainTermResult of
        Ok domainTerm ->
          let prod = domainTermForm.product
              newDomainTermsList = domainTerm :: prod.domainTerms
              updatedProduct = { prod | domainTerms = newDomainTermsList }
              newView = { domainTermForm | product = updatedProduct }
          in (newView, Effects.none)
        Err _ -> crash "Something went wrong!"

    ShowDomainTermForm ->
      ({ domainTermForm | domainTermFormVisible = True }, Effects.none)

    HideDomainTermForm ->
      ({ domainTermForm | domainTermFormVisible = False }, Effects.none)

    SetDomainTermTitle newTitle ->
      let newDomainTerm = domainTermForm.newDomainTerm
          updatedDomainTerm = { newDomainTerm | title = newTitle }
      in ({ domainTermForm | newDomainTerm = updatedDomainTerm }, Effects.none)

    SetDomainTermDescription newDescription ->
      let newDomainTerm = domainTermForm.newDomainTerm
          updatedDomainTerm = { newDomainTerm | description = newDescription }
      in ({ domainTermForm | newDomainTerm = updatedDomainTerm }, Effects.none)

    SubmitDomainTermForm ->
      case validate domainTermForm.newDomainTerm of
        Left errorModel ->
          ( { domainTermForm | formState = HasError }
          , Effects.none
          )
        Right domainTerm ->
          ( { domainTermForm | formState = Valid }
          , createDomainTerm (domainTermsUrl domainTermForm.product) domainTerm
          )

validate : DomainTerm -> Either DomainTerm DomainTerm
validate domainTerm =
  case (isTitleFieldValid domainTerm)
    || (isDescriptionFieldValid domainTerm) of
    True  -> Left domainTerm
    False -> Right domainTerm

isTitleFieldValid : DomainTerm -> Bool
isTitleFieldValid domainTerm =
  isEmpty domainTerm.title

isDescriptionFieldValid : DomainTerm -> Bool
isDescriptionFieldValid domainTerm =
  isEmpty domainTerm.description

view : Signal.Address Action -> DomainTermForm -> Html
view address domainTermForm =
  if domainTermForm.domainTermFormVisible
    then
      let domainTermFormHtml = renderDomainTermForm address domainTermForm
      in Html.div [] [ domainTermFormHtml ]
    else
      Html.a
      [ href "#", onClick address ShowDomainTermForm ]
      [ Html.text "Create Domain Term" ]

renderDomainTermForm : Signal.Address Action -> DomainTermForm -> Html
renderDomainTermForm address domainTermForm =
  let headingContent = Html.text "Create A New Domain Term"
      bodyContent    = renderForm address domainTermForm
  in UI.panelWithHeading headingContent bodyContent

renderForm : Signal.Address Action -> DomainTermForm -> Html
renderForm address domainTermForm =
  let domainTerm = domainTermForm.newDomainTerm
      domainTermTitleInputData =
        { address = address
        , inputName = "domainTermTitle"
        , labelContent = Html.text "Title"
        , inputParser = SetDomainTermTitle
        , hasError = isTitleFieldValid domainTerm
        }
      domainTermDescriptionInputData =
        { address = address
        , inputName = "domainTermDescription"
        , labelContent = Html.text "Description"
        , inputParser = SetDomainTermDescription
        , hasError = isDescriptionFieldValid domainTerm
        }
  in
    Html.div
      []
      [ UI.input' domainTermTitleInputData
      , UI.textarea' domainTermDescriptionInputData
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
