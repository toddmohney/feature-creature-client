module App.Products.DomainTerms.Forms.ViewModel
  ( DomainTermForm
  , init
  , setDescription
  , setProduct
  , setTitle
  ) where

import App.Products.DomainTerms.DomainTerm as DT exposing (DomainTerm)
import App.Products.DomainTerms.Forms.Actions    exposing (..)
import App.Products.Product                      exposing (Product)
import Html                                      exposing (Html)
import UI.App.Primitives.Forms                   exposing (InputField)

type alias DomainTermForm =
  { product          : Product
  , formObject       : DomainTerm
  , titleField       : InputField DomainTermFormAction
  , descriptionField : InputField DomainTermFormAction
  }

init : Product -> DomainTerm -> DomainTermForm
init prod domainTerm =
  { product          = prod
  , formObject       = domainTerm
  , titleField       = defaultTitleField domainTerm
  , descriptionField = defaultDescriptionField domainTerm
  }

setProduct : DomainTermForm -> Product -> DomainTermForm
setProduct domainTermForm prod =
  { domainTermForm | product = prod }

setTitle : DomainTermForm -> String -> DomainTermForm
setTitle { product, formObject } newTitle =
  let updatedDomainTerm = { formObject | title = newTitle }
  in
    init product updatedDomainTerm

setDescription : DomainTermForm -> String -> DomainTermForm
setDescription { product, formObject } newDescription =
  let updatedDomainTerm = { formObject | description = newDescription }
  in
    init product updatedDomainTerm

defaultTitleField : DomainTerm -> InputField DomainTermFormAction
defaultTitleField domainTerm =
  { defaultValue     = domainTerm.title
  , inputName        = "domainTermTitle"
  , inputParser      = SetDomainTermTitle
  , labelContent     = (Html.text "Title")
  , validationErrors = []
  }

defaultDescriptionField : DomainTerm -> InputField DomainTermFormAction
defaultDescriptionField domainTerm =
  { defaultValue     = domainTerm.description
  , inputName        = "domainTermDescription"
  , inputParser      = SetDomainTermDescription
  , labelContent     = (Html.text "Description")
  , validationErrors = []
  }
