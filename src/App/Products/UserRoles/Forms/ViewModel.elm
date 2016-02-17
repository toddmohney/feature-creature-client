module App.Products.UserRoles.Forms.ViewModel
  ( UserRoleForm
  , init
  ) where

import Html                                  exposing (Html)
import App.Products.UserRoles.Forms.Actions  exposing (..)
import App.Products.Product                  exposing (Product)
import App.Products.UserRoles.UserRole as UR exposing (UserRole)
import UI.App.Primitives.Forms     as UI     exposing (InputField)

type alias UserRoleForm =
  { product : Product
  , userRoleFormVisible  : Bool
  , newUserRole          : UserRole
  , titleField           : InputField Action
  , descriptionField     : InputField Action
  }

init : Product -> UserRole -> UserRoleForm
init prod userRole =
  { product              = prod
  , userRoleFormVisible  = False
  , newUserRole          = userRole
  , titleField           = defaultTitleField userRole
  , descriptionField     = defaultDescriptionField userRole
  }

defaultTitleField : UserRole -> InputField Action
defaultTitleField userRole =
  { defaultValue = userRole.title
  , inputName = "userRoleTitle"
  , labelContent = (Html.text "Title")
  , inputParser = SetUserRoleTitle
  , validationErrors = []
  }

defaultDescriptionField : UserRole -> InputField Action
defaultDescriptionField userRole =
  { defaultValue = userRole.description
  , inputName = "userRoleDescription"
  , labelContent = (Html.text "Description")
  , inputParser = SetUserRoleDescription
  , validationErrors = []
  }
