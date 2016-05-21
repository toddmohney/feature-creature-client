module App.Products.DomainTerms.Forms.ViewModel exposing
  ( DomainTermForm
  , FormMode(..)
  , init
  , setDescription
  , setProduct
  , setTitle
  )

import App.Products.DomainTerms.DomainTerm as DT exposing (DomainTerm)
import App.Products.DomainTerms.Messages         exposing (Msg(..))
import App.Products.Product                      exposing (Product)
import Html                                      exposing (Html)
import UI.App.Primitives.Forms                   exposing (InputField)

type FormMode = Create
              | Edit

type alias DomainTermForm =
  { formMode         : FormMode
  , formObject       : DomainTerm
  , product          : Product
  , titleField       : InputField Msg
  , descriptionField : InputField Msg
  }

init : Product -> DomainTerm -> FormMode -> DomainTermForm
init prod domainTerm formMode =
  { formMode         = formMode
  , formObject       = domainTerm
  , product          = prod
  , titleField       = defaultTitleField domainTerm
  , descriptionField = defaultDescriptionField domainTerm
  }

setProduct : DomainTermForm -> Product -> DomainTermForm
setProduct domainTermForm prod =
  { domainTermForm | product = prod }

setTitle : DomainTermForm -> String -> DomainTermForm
setTitle domainTermForm newTitle =
  let formObject = domainTermForm.formObject
      updatedDomainTerm = { formObject | title = newTitle }
  in
    -- run through 'init' so we end up with
    -- correctly initialized fields
    init domainTermForm.product updatedDomainTerm domainTermForm.formMode

setDescription : DomainTermForm -> String -> DomainTermForm
setDescription domainTermForm newDescription =
  let formObject = domainTermForm.formObject
      updatedDomainTerm = { formObject | description = newDescription }
  in
    -- run through 'init' so we end up with
    -- correctly initialized fields
    init domainTermForm.product updatedDomainTerm domainTermForm.formMode

defaultTitleField : DomainTerm -> InputField Msg
defaultTitleField domainTerm =
  { defaultValue     = domainTerm.title
  , inputName        = "domainTermTitle"
  , inputParser      = SetDomainTermTitle
  , labelContent     = (Html.text "Title")
  , validationErrors = []
  }

defaultDescriptionField : DomainTerm -> InputField Msg
defaultDescriptionField domainTerm =
  { defaultValue     = domainTerm.description
  , inputName        = "domainTermDescription"
  , inputParser      = SetDomainTermDescription
  , labelContent     = (Html.text "Description")
  , validationErrors = []
  }
