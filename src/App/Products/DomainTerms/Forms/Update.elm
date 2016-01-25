module App.Products.DomainTerms.Forms.Update
  ( update ) where

import App.AppConfig                             exposing (..)
import App.Products.DomainTerms.Forms.Actions    exposing (..)
import App.Products.DomainTerms.Forms.ViewModel  exposing (DomainTermForm)
import App.Products.DomainTerms.Forms.Validation exposing (validateForm, hasErrors)
import App.Products.DomainTerms.Requests         exposing (createDomainTerm)
import Debug                                     exposing (crash)
import Effects                                   exposing (Effects)

update : DomainTermFormAction -> DomainTermForm -> AppConfig -> (DomainTermForm, Effects DomainTermFormAction)
update action domainTermForm appConfig =
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
             , createDomainTerm appConfig newDomainTermForm.product newDomainTermForm.newDomainTerm AddDomainTerm
             )
