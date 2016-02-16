module App.Products.DomainTerms.Forms.ViewModel
  ( DomainTermForm
  , init
  ) where

import App.Products.DomainTerms.DomainTerm as DT exposing (DomainTerm)
import App.Products.DomainTerms.Forms.Actions    exposing (..)
import App.Products.Product                      exposing (Product)
import Html                                  exposing (Html)
import UI.App.Primitives.Forms               exposing (InputField)

type alias DomainTermForm =
  { product : Product
  , domainTermFormVisible : Bool
  , formObject            : DomainTerm
  , titleField            : InputField DomainTermFormAction
  , descriptionField      : InputField DomainTermFormAction
  }

init : Product -> DomainTermForm
init prod =
  { product               = prod
  , domainTermFormVisible = False
  , formObject            = DT.init
  , titleField            = defaultTitleField
  , descriptionField      = defaultDescriptionField
  }

defaultTitleField : InputField DomainTermFormAction
defaultTitleField =
  { inputName        = "domainTermTitle"
  , labelContent     = (Html.text "Title")
  , inputParser      = SetDomainTermTitle
  , validationErrors = []
  }

defaultDescriptionField : InputField DomainTermFormAction
defaultDescriptionField =
  { inputName        = "domainTermDescription"
  , labelContent     = (Html.text "Description")
  , inputParser      = SetDomainTermDescription
  , validationErrors = []
  }
