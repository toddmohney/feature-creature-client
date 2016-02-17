module App.Products.DomainTerms.Forms.Update
  ( update ) where

import App.AppConfig                                   exposing (..)
import App.Products.Product as P
import App.Products.DomainTerms.DomainTerm as DT
import App.Products.DomainTerms.Forms.Actions          exposing (..)
import App.Products.DomainTerms.Forms.ViewModel as DTF exposing (DomainTermForm)
import App.Products.DomainTerms.Forms.Validation       exposing (validateForm, hasErrors)
import App.Products.DomainTerms.Requests               exposing (createDomainTerm)
import Debug                                           exposing (crash)
import Effects                                         exposing (Effects)

update : DomainTermFormAction -> DomainTermForm -> AppConfig -> (DomainTermForm, Effects DomainTermFormAction)
update action domainTermForm appConfig =
  case action of
    ShowDomainTermForm ->
      ({ domainTermForm | isVisible = True }, Effects.none)

    HideDomainTermForm ->
      (DTF.init domainTermForm.product DT.init, Effects.none)

    SetDomainTermTitle newTitle ->
      (DTF.setTitle domainTermForm newTitle, Effects.none)

    SetDomainTermDescription newDescription ->
      (DTF.setDescription domainTermForm newDescription, Effects.none)

    EditDomainTerm domainTerm ->
      let product = domainTermForm.product
          newForm = DTF.init product domainTerm
      in
        ({ newForm | isVisible = True }, Effects.none)

    AddDomainTerm domainTermResult ->
      case domainTermResult of
        Ok domainTerm ->
          let updatedProduct = P.addDomainTerm domainTermForm.product domainTerm
              newForm        = DTF.init updatedProduct DT.init
          in
            (newForm, Effects.none)
        Err _ -> crash "Something went wrong!"

    SubmitDomainTermForm ->
      let newDomainTermForm = validateForm domainTermForm
      in
        case hasErrors newDomainTermForm of
          True ->
            (newDomainTermForm , Effects.none)
          False ->
            (,)
            newDomainTermForm
            (createDomainTerm appConfig newDomainTermForm.product newDomainTermForm.formObject AddDomainTerm)
