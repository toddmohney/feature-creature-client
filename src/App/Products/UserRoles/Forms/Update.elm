module App.Products.UserRoles.Forms.Update
  ( update ) where

import App.AppConfig                                 exposing (..)
import App.Products.UserRoles.Forms.Actions          exposing (..)
import App.Products.UserRoles.Forms.ViewModel as URF exposing (UserRoleForm)
import App.Products.UserRoles.Forms.Validation       exposing (hasErrors, validateForm)
import App.Products.UserRoles.Requests               exposing (createUserRole, editUserRole)
import App.Products.UserRoles.UserRole as UR
import Debug                                         exposing (crash)
import Effects                                       exposing (Effects)
import Task

update : Action -> UserRoleForm -> AppConfig -> (UserRoleForm, Effects Action)
update action userRoleForm appConfig =
  case action of
    UserRoleAdded userRole   -> (userRoleForm, Effects.none)
    UserRoleUpdated userRole -> (userRoleForm, Effects.none)

    UserRoleCreated userRoleResult ->
      case userRoleResult of
        Ok userRole ->
          let newForm = URF.init userRoleForm.product UR.init URF.Create
              effects = Effects.task (Task.succeed (UserRoleAdded userRole))
          in
            (newForm, effects)
        Err _ -> crash "Something went wrong!"

    UserRoleModified userRoleResult ->
      case userRoleResult of
        Ok userRole ->
          let newForm = URF.init userRoleForm.product UR.init URF.Create
              effects = Effects.task (Task.succeed (UserRoleUpdated userRole))
          in
            (newForm, effects)
        Err _ -> crash "Something went wrong!"

    SetUserRoleTitle newTitle ->
      (URF.setTitle userRoleForm newTitle, Effects.none)

    SetUserRoleDescription newDescription ->
      (URF.setDescription userRoleForm newDescription, Effects.none)

    SubmitUserRoleForm ->
      let newUserRoleForm = validateForm userRoleForm
      in
        case hasErrors newUserRoleForm of
          True ->
            (newUserRoleForm , Effects.none)
          False ->
            submitUserRoleForm newUserRoleForm appConfig


submitUserRoleForm : UserRoleForm -> AppConfig -> (UserRoleForm, Effects Action)
submitUserRoleForm userRoleForm appConfig =
  case userRoleForm.formMode of
    URF.Create ->
      (,)
      userRoleForm
      (createUserRole appConfig userRoleForm.product userRoleForm.formObject UserRoleCreated)
    URF.Edit ->
      (,)
      userRoleForm
      (editUserRole appConfig userRoleForm.product userRoleForm.formObject UserRoleModified)
