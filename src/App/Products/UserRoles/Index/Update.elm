module App.Products.UserRoles.Index.Update
  ( update
  ) where

import App.AppConfig                                 exposing (..)
import App.Products.UserRoles.Actions                exposing (Action(..))
import App.Products.UserRoles.Forms.Update as URF
import App.Products.UserRoles.Index.ViewModel        exposing (UserRolesView)
import Data.External                                 exposing (External(..))
import Debug                                         exposing (crash)
import Effects                                       exposing (Effects)

update : Action -> UserRolesView -> AppConfig -> (UserRolesView, Effects Action)
update action userRolesView appConfig =
  case action of
    -- This is smelly. The UserRoleFrom is allowed to update the Product,
    -- so we need to update both this model and the form model.
    -- Try to refactor to let the updates flow in One Direction
    UpdateUserRoles userRolesResult ->
      case userRolesResult of
        Ok userRoleList ->
          let prod = userRolesView.product
              updatedProduct = { prod | userRoles = Loaded userRoleList }
              userRoleForm = userRolesView.userRoleForm
              newUserRoleForm = { userRoleForm | product = updatedProduct }
              newView = { userRolesView |
                          product = updatedProduct
                        , userRoleForm = newUserRoleForm
                        }
          in (newView, Effects.none)
        Err _ -> crash "Something went wrong!"

    -- This is smelly. The UserRoleFrom is allowed to update the Product,
    -- so we need to update both this model and the form model.
    -- Try to refactor to let the updates flow in One Direction
    UserRoleFormAction dtFormAction ->
      let (dtForm, dtFormFx) = URF.update dtFormAction userRolesView.userRoleForm appConfig
          prod = userRolesView.product
          updatedProduct = { prod | userRoles = dtForm.product.userRoles }
          updatedUserRolesView = { userRolesView |
                                     userRoleForm = dtForm
                                   , product = updatedProduct
                                   }
      in ( updatedUserRolesView
         , Effects.map UserRoleFormAction dtFormFx
         )
    SearchFeatures query ->
      -- noop
      (userRolesView, Effects.none)
