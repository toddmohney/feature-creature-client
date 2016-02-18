module App.Products.UserRoles.Forms.ViewModel
  ( UserRoleForm
  , FormMode(..)
  , init
  , setProduct
  , setTitle
  , setDescription
  ) where

import Html                                  exposing (Html)
import App.Products.UserRoles.Forms.Actions  exposing (..)
import App.Products.Product                  exposing (Product)
import App.Products.UserRoles.UserRole as UR exposing (UserRole)
import UI.App.Primitives.Forms     as UI     exposing (InputField)

type FormMode = Create
              | Edit

type alias UserRoleForm =
  { formMode         : FormMode
  , formObject       : UserRole
  , product          : Product
  , titleField       : InputField Action
  , descriptionField : InputField Action
  }

init : Product -> UserRole -> FormMode -> UserRoleForm
init prod userRole formMode =
  { formMode         = formMode
  , formObject       = userRole
  , product          = prod
  , titleField       = defaultTitleField userRole
  , descriptionField = defaultDescriptionField userRole
  }

setProduct : UserRoleForm -> Product -> UserRoleForm
setProduct userRoleForm prod =
  { userRoleForm | product = prod }

setTitle : UserRoleForm -> String -> UserRoleForm
setTitle userRoleForm newTitle =
  let formObject = userRoleForm.formObject
      updatedUserRole = { formObject | title = newTitle }
  in
    -- run through 'init' so we end up with
    -- correctly initialized fields
    init userRoleForm.product updatedUserRole userRoleForm.formMode

setDescription : UserRoleForm -> String -> UserRoleForm
setDescription userRoleForm newDescription =
  let formObject = userRoleForm.formObject
      updatedUserRole = { formObject | description = newDescription }
  in
    -- run through 'init' so we end up with
    -- correctly initialized fields
    init userRoleForm.product updatedUserRole userRoleForm.formMode

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
