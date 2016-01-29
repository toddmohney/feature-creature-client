module App.Products.UserRoles.Forms.Update
  ( update ) where

import App.AppConfig                           exposing (..)
import App.Products.UserRoles.Forms.Actions    exposing (..)
import App.Products.UserRoles.Forms.ViewModel  exposing (UserRoleForm)
import App.Products.UserRoles.Forms.Validation exposing (hasErrors, validateForm)
import App.Products.UserRoles.Requests         exposing (createUserRole)
import App.Products.Product as P
import Debug                                   exposing (crash)
import Effects                                 exposing (Effects)

update : Action -> UserRoleForm -> AppConfig -> (UserRoleForm, Effects Action)
update action userRoleForm appConfig =
  case action of
    AddUserRole userRoleResult ->
      case userRoleResult of
        Ok userRole ->
          let updatedProduct = P.addUserRole userRoleForm.product userRole
              newView        = { userRoleForm | product = updatedProduct }
          in
            (newView, Effects.none)
        Err _ ->
          crash "Something went wrong!"

    ShowUserRoleForm ->
      ({ userRoleForm | userRoleFormVisible = True }, Effects.none)

    HideUserRoleForm ->
      ({ userRoleForm | userRoleFormVisible = False }, Effects.none)

    SetUserRoleTitle newTitle ->
      let newUserRole     = userRoleForm.newUserRole
          updatedUserRole = { newUserRole | title    = newTitle }
      in ({ userRoleForm | newUserRole = updatedUserRole }, Effects.none)

    SetUserRoleDescription newDescription ->
      let newUserRole     = userRoleForm.newUserRole
          updatedUserRole = { newUserRole | description = newDescription }
      in ({ userRoleForm | newUserRole = updatedUserRole }, Effects.none)

    SubmitUserRoleForm ->
      let newUserRoleForm = validateForm userRoleForm
      in
         case hasErrors newUserRoleForm of
           True ->
             ( newUserRoleForm
             , Effects.none
             )
           False ->
             ( newUserRoleForm
             , createUserRole appConfig newUserRoleForm.product newUserRoleForm.newUserRole AddUserRole
             )
