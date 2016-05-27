module App.Products.DomainTerms.Forms.Update exposing ( update )

import App.AppConfig                                   exposing (..)
import App.Products.DomainTerms.DomainTerm as DT
import App.Products.DomainTerms.Forms.ViewModel as DTF exposing (DomainTermForm)
import App.Products.DomainTerms.Forms.Validation       exposing (validateForm, hasErrors)
import App.Products.DomainTerms.Messages               exposing (Msg(..))
import App.Products.DomainTerms.Requests               exposing (createDomainTerm, editDomainTerm)
import Debug                                           exposing (crash)

update : Msg -> DomainTermForm -> AppConfig -> (DomainTermForm, Cmd Msg)
update action domainTermForm appConfig =
  case action of
    CreateDomainTermSucceeded domainTerm ->
      (DTF.init domainTermForm.product DT.init DTF.Create , Cmd.none)

    CreateDomainTermFailed err -> crash "Failed to create new domain term."

    UpdateDomainTermSucceeded domainTerm ->
      ( DTF.init domainTermForm.product DT.init DTF.Create
      , Cmd.none
      )

    UpdateDomainTermFailed err -> crash "Unable to update domain term."

    SetDomainTermTitle newTitle -> (DTF.setTitle domainTermForm newTitle, Cmd.none)

    SetDomainTermDescription newDescription -> (DTF.setDescription domainTermForm newDescription, Cmd.none)

    SubmitDomainTermForm ->
      let newDomainTermForm = validateForm domainTermForm
      in
        case hasErrors newDomainTermForm of
          True ->
            (newDomainTermForm , Cmd.none)
          False ->
            submitDomainTermForm newDomainTermForm appConfig

    _ -> (domainTermForm, Cmd.none)


submitDomainTermForm : DomainTermForm -> AppConfig -> (DomainTermForm, Cmd Msg)
submitDomainTermForm domainTermForm appConfig =
  case domainTermForm.formMode of
    DTF.Create ->
      (,)
      domainTermForm
      (createDomainTerm appConfig domainTermForm.product domainTermForm.formObject)
    DTF.Edit ->
      (,)
      domainTermForm
      (editDomainTerm appConfig domainTermForm.product domainTermForm.formObject)
