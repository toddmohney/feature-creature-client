module Products.UserRoles.Forms.Update where

import Debug                             exposing (crash)
import Effects                           exposing (Effects)
import Http                              exposing (Error)
import Products.Product                  exposing (Product)
import Products.UserRoles.Forms.Actions exposing (..)
import Products.UserRoles.Forms.Model    exposing (..)
import Products.UserRoles.Forms.Validation    exposing (..)
import Products.UserRoles.UserRole as UR exposing (UserRole)
import Task                              exposing (Task)
import Utils.Http

update : Action -> UserRoleForm -> (UserRoleForm, Effects Action)
update action userRoleForm =
  case action of
    AddUserRole userRoleResult ->
      case userRoleResult of
        Ok userRole ->
          let prod             = userRoleForm.product
              newUserRolesList = userRole :: prod.userRoles
              updatedProduct   = { prod | userRoles = newUserRolesList }
              newView          = { userRoleForm | product = updatedProduct }
          in (newView, Effects.none)
        Err _ -> crash "Something went wrong!"

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
             , createUserRole (userRolesUrl newUserRoleForm.product) newUserRoleForm.newUserRole
             )

userRolesUrl : Product -> String
userRolesUrl prod = "http://localhost:8081/products/" ++ (toString prod.id) ++ "/user-roles"

createUserRole : String -> UserRole -> Effects Action
createUserRole url userRole =
  let request = Utils.Http.jsonPostRequest url (UR.encodeUserRole userRole)
  in Http.send Http.defaultSettings request
     |> Http.fromJson UR.parseUserRole
     |> Task.toResult
     |> Task.map AddUserRole
     |> Effects.task
