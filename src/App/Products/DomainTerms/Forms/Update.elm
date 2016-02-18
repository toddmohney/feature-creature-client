module App.Products.DomainTerms.Forms.Update
  ( update ) where

import App.AppConfig                                   exposing (..)
import App.Products.DomainTerms.DomainTerm as DT
import App.Products.DomainTerms.Forms.Actions          exposing (..)
import App.Products.DomainTerms.Forms.ViewModel as DTF exposing (DomainTermForm)
import App.Products.DomainTerms.Forms.Validation       exposing (validateForm, hasErrors)
import App.Products.DomainTerms.Requests               exposing (createDomainTerm, editDomainTerm)
import Debug                                           exposing (crash)
import Effects                                         exposing (Effects)
import Task

update : DomainTermFormAction -> DomainTermForm -> AppConfig -> (DomainTermForm, Effects DomainTermFormAction)
update action domainTermForm appConfig =
  case action of
    DomainTermAdded domainTerm   -> (domainTermForm, Effects.none)
    DomainTermUpdated domainTerm -> (domainTermForm, Effects.none)

    DomainTermCreated domainTermResult ->
      case domainTermResult of
        Ok domainTerm ->
          let newForm = DTF.init domainTermForm.product DT.init DTF.Create
              effects = Effects.task (Task.succeed (DomainTermAdded domainTerm))
          in
            (newForm, effects)
        Err _ -> crash "Something went wrong!"

    DomainTermModified domainTermResult ->
      case domainTermResult of
        Ok domainTerm ->
          let newForm = DTF.init domainTermForm.product DT.init DTF.Create
              effects = Effects.task (Task.succeed (DomainTermUpdated domainTerm))
          in
            (newForm, effects)
        Err _ -> crash "Something went wrong!"

    SetDomainTermTitle newTitle ->
      (DTF.setTitle domainTermForm newTitle, Effects.none)

    SetDomainTermDescription newDescription ->
      (DTF.setDescription domainTermForm newDescription, Effects.none)

    SubmitDomainTermForm ->
      let newDomainTermForm = validateForm domainTermForm
      in
        case hasErrors newDomainTermForm of
          True ->
            (newDomainTermForm , Effects.none)
          False ->
            submitDomainTermForm newDomainTermForm appConfig


submitDomainTermForm : DomainTermForm -> AppConfig -> (DomainTermForm, Effects DomainTermFormAction)
submitDomainTermForm domainTermForm appConfig =
  case domainTermForm.formMode of
    DTF.Create ->
      (,)
      domainTermForm
      (createDomainTerm appConfig domainTermForm.product domainTermForm.formObject DomainTermCreated)
    DTF.Edit ->
      (,)
      domainTermForm
      (editDomainTerm appConfig domainTermForm.product domainTermForm.formObject DomainTermModified)
