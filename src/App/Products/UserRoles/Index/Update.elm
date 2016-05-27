module App.Products.UserRoles.Index.Update exposing ( update )

import App.AppConfig                                 exposing (..)
import App.Products.UserRoles.Forms.ViewModel as URF
import App.Products.UserRoles.Forms.Update as URF
import App.Products.UserRoles.Messages               exposing (..)
import App.Products.UserRoles.Index.ViewModel        exposing (UserRolesView)
import App.Products.UserRoles.Requests               exposing (getUserRolesList, removeUserRole)
import App.Products.UserRoles.UserRole    as UR
import Data.External                                 exposing (External(..))
import Debug                                         exposing (crash)

update : Msg -> UserRolesView -> AppConfig -> (UserRolesView, Cmd Msg)
update action userRolesView appConfig =
  case action of
    FetchUserRolesSucceeded userRoles ->
      let product           = userRolesView.product
          userRoleForm      = userRolesView.userRoleForm
          updatedProduct    = { product | userRoles = Loaded userRoles }
          newUserRoleForm = Maybe.map2 URF.setProduct userRoleForm (Just updatedProduct)
          newView = { userRolesView |
                      product = updatedProduct
                    , userRoleForm = newUserRoleForm
                    }
      in (newView, Cmd.none)

    CreateUserRoleSucceeded _ ->
      (userRolesView, getUserRolesList appConfig userRolesView.product)

    UpdateUserRoleSucceeded _ ->
      (userRolesView, getUserRolesList appConfig userRolesView.product)

    DeleteUserRoleSucceeded _ ->
      (userRolesView, getUserRolesList appConfig userRolesView.product)

    FetchUserRolesFailed _ -> crash "Unable to fetch user roles"

    CreateUserRoleFailed _ -> crash "Unable to create new user role"

    UpdateUserRoleFailed _ -> crash "Unable to update user role"

    DeleteUserRoleFailed _ -> crash "Unable to delete user role"

    RemoveUserRole userRole ->
      (userRolesView, removeUserRole appConfig userRolesView.product userRole)

    ShowCreateUserRoleForm ->
      let product = userRolesView.product
          newForm = URF.init product UR.init URF.Create
      in
        ({ userRolesView | userRoleForm = Just newForm }, Cmd.none)

    ShowEditUserRoleForm userRole ->
      let product = userRolesView.product
          newForm = URF.init product userRole URF.Edit
      in
        ({ userRolesView | userRoleForm = Just newForm }, Cmd.none)

    HideUserRoleForm ->
      ({ userRolesView | userRoleForm = Nothing }, Cmd.none)

    SearchFeatures searchQuery -> (userRolesView, Cmd.none)

    _ ->
      case userRolesView.userRoleForm of
        Nothing -> (userRolesView, Cmd.none)
        Just userRoleForm ->
          let (dtForm, dtFormFx) = URF.update action userRoleForm appConfig
          in
            ( { userRolesView | userRoleForm = Just dtForm }
            , dtFormFx
            )
