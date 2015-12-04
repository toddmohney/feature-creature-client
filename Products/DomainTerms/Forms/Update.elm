module Products.DomainTerms.Forms.Update where

import Debug                                 exposing (crash)
import Effects                               exposing (Effects)
import Http                                  exposing (Error)
import Products.Product                      exposing (Product)
import Products.DomainTerms.DomainTerm as DT exposing (DomainTerm)
import Products.DomainTerms.Forms.Actions    exposing (..)
import Products.DomainTerms.Forms.Model      exposing (..)
import Products.DomainTerms.Forms.Validation exposing (..)
import Task                                  exposing (Task)
import Utils.Http

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
      let newDomainTermForm = validateForm domainTermForm
      in
         case hasErrors newDomainTermForm of
           True ->
             ( newDomainTermForm
             , Effects.none
             )
           False ->
             ( newDomainTermForm
             , createDomainTerm (domainTermsUrl newDomainTermForm.product) newDomainTermForm.newDomainTerm
             )

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
