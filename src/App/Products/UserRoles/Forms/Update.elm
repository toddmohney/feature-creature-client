module App.Products.UserRoles.Forms.Update exposing ( update )

import App.AppConfig                                 exposing (..)
import App.Products.UserRoles.Messages               exposing (..)
import App.Products.UserRoles.Forms.ViewModel as URF exposing (UserRoleForm)
import App.Products.UserRoles.Forms.Validation       exposing (hasErrors, validateForm)
import App.Products.UserRoles.Requests               exposing (createUserRole, editUserRole)
import App.Products.UserRoles.UserRole as UR
import Debug                                         exposing (crash)

update : Msg -> UserRoleForm -> AppConfig -> (UserRoleForm, Cmd Msg)
update action userRoleForm appConfig =
  case action of
    UserRoleAdded userRole   -> (userRoleForm, Cmd.none)
    UserRoleUpdated userRole -> (userRoleForm, Cmd.none)

    UserRoleCreated userRoleResult ->
      case userRoleResult of
        Ok userRole ->
          let newForm = URF.init userRoleForm.product UR.init URF.Create
              cmd = Cmd.map (\_-> UserRoleAdded userRole) Cmd.none
          in
            (newForm, cmd)
        Err _ -> crash "Something went wrong!"

    UserRoleModified userRoleResult ->
      case userRoleResult of
        Ok userRole ->
          let newForm = URF.init userRoleForm.product UR.init URF.Create
              cmd = Cmd.map (\_ -> UserRoleUpdated userRole) Cmd.none
          in
            (newForm, cmd)
        Err _ -> crash "Something went wrong!"

    SetUserRoleTitle newTitle ->
      (URF.setTitle userRoleForm newTitle, Cmd.none)

    SetUserRoleDescription newDescription ->
      (URF.setDescription userRoleForm newDescription, Cmd.none)

    SubmitUserRoleForm ->
      let newUserRoleForm = validateForm userRoleForm
      in
        case hasErrors newUserRoleForm of
          True ->
            (newUserRoleForm , Cmd.none)
          False ->
            submitUserRoleForm newUserRoleForm appConfig

    _ -> (userRoleForm, Cmd.none)


submitUserRoleForm : UserRoleForm -> AppConfig -> (UserRoleForm, Cmd Msg)
submitUserRoleForm userRoleForm appConfig =
  case userRoleForm.formMode of
    URF.Create ->
      (,)
      userRoleForm
      (createUserRole appConfig userRoleForm.product userRoleForm.formObject)
    URF.Edit ->
      (,)
      userRoleForm
      (editUserRole appConfig userRoleForm.product userRoleForm.formObject)
