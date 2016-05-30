module App.Products.DomainTerms.Forms.Validation exposing
  ( validateForm
  , hasErrors
  )

import App.Products.DomainTerms.Forms.ViewModel exposing (..)
import UI.App.Primitives.Forms     as UI        exposing (..)

validateForm : DomainTermForm -> DomainTermForm
validateForm form =
  let domainTerm          = form.formObject
      titleField          = form.titleField
      descriptionField    = form.descriptionField
      newTitleField       = { titleField | validationErrors       = validateTitle domainTerm.title }
      newDescriptionField = { descriptionField | validationErrors = validateDescription domainTerm.description }
  in
     { form | titleField = newTitleField
            , descriptionField = newDescriptionField
     }

validateTitle : String -> (List String)
validateTitle = requiredStringFieldValidation

validateDescription : String -> (List String)
validateDescription = requiredStringFieldValidation

hasErrors : DomainTermForm -> Bool
hasErrors = not << isSubmittable

isSubmittable : DomainTermForm -> Bool
isSubmittable domainTermForm =
  let titleField       = domainTermForm.titleField
      descriptionField = domainTermForm.descriptionField
  in
     (List.isEmpty titleField.validationErrors)
     && (List.isEmpty descriptionField.validationErrors)
