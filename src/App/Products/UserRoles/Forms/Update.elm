module App.Products.UserRoles.Forms.Update exposing ( update )

import App.AppConfig                                 exposing (..)
import App.Products.UserRoles.Messages               exposing (..)
import App.Products.UserRoles.Forms.ViewModel as URF exposing (UserRoleForm)
import App.Products.UserRoles.Forms.Validation       exposing (hasErrors, validateForm)
import App.Products.UserRoles.Requests               exposing (createUserRole, editUserRole)
import App.Products.UserRoles.UserRole as UR

update : Msg -> UserRoleForm -> AppConfig -> (UserRoleForm, Cmd Msg)
update action userRoleForm appConfig =
  case action of
    CreateUserRoleSucceeded userRole ->
      ( URF.init userRoleForm.product UR.init URF.Create
      , Cmd.none
      )

    UpdateUserRoleSucceeded userRole ->
      ( URF.init userRoleForm.product UR.init URF.Create
      , Cmd.none
      )

    SetUserRoleTitle newTitle ->
      (URF.setTitle userRoleForm newTitle, Cmd.none)

    SetUserRoleDescription newDescription ->
      (URF.setDescription userRoleForm newDescription, Cmd.none)

    SubmitUserRoleForm ->
      let newUserRoleForm = validateForm userRoleForm
      in
        case hasErrors newUserRoleForm of
          True -> (newUserRoleForm , Cmd.none)
          False -> submitUserRoleForm newUserRoleForm appConfig

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
