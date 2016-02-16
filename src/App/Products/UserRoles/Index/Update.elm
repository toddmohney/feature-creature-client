module App.Products.UserRoles.Index.Update
  ( update
  ) where

import App.AppConfig                                 exposing (..)
import App.Products.UserRoles.Actions                exposing (UserRoleAction(..))
import App.Products.UserRoles.Forms.Update as URF
import App.Products.UserRoles.Index.ViewModel        exposing (UserRolesView)
import App.Products.UserRoles.Requests               exposing (getUserRolesList, removeUserRole)
import Data.External                                 exposing (External(..))
import Debug                                         exposing (crash)
import Effects                                       exposing (Effects)

update : UserRoleAction -> UserRolesView -> AppConfig -> (UserRolesView, Effects UserRoleAction)
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

    EditUserRole userRole -> (userRolesView, Effects.none)

    RemoveUserRole userRole ->
      (,)
      userRolesView
      (removeUserRole appConfig userRolesView.product userRole UserRoleRemoved)

    UserRoleRemoved result ->
      -- This always results in an error, even with a 200 response,
      -- because Elm cannot parse an empty response body.
      -- We can make this better, however.
      -- see: https://github.com/evancz/elm-http/issues/5
      case result of
        Ok a ->
          (,)
          userRolesView
          (getUserRolesList appConfig userRolesView.product UpdateUserRoles)
        Err err ->
          (,)
          userRolesView
          (getUserRolesList appConfig userRolesView.product UpdateUserRoles)
