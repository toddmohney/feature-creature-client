module Products.DomainTerms.Forms.Model where

import Html                                  exposing (Html)
import Products.DomainTerms.DomainTerm as DT exposing (DomainTerm)
import Products.DomainTerms.Forms.Actions    exposing (..)
import Products.Product                      exposing (Product)
import UI.App.Primitives.Forms     as UI     exposing (..)

type alias DomainTermForm =
  { product : Product
  , domainTermFormVisible : Bool
  , newDomainTerm         : DomainTerm
  , titleField            : InputField Action
  , descriptionField      : InputField Action
  }

init : Product -> DomainTermForm
init prod =
  { product = prod
  , domainTermFormVisible = False
  , newDomainTerm = DT.init
  , titleField           = defaultTitleField
  , descriptionField     = defaultDescriptionField
  }

defaultTitleField : InputField Action
defaultTitleField =
  { inputName = "domainTermTitle"
  , labelContent = (Html.text "Title")
  , inputParser = SetDomainTermTitle
  , validationErrors = []
  }

defaultDescriptionField : InputField Action
defaultDescriptionField =
  { inputName = "domainTermDescription"
  , labelContent = (Html.text "Description")
  , inputParser = SetDomainTermDescription
  , validationErrors = []
  }
