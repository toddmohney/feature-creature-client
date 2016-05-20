module App.Products.UserRoles.Index.Update exposing ( update )

import App.AppConfig                                 exposing (..)
import App.Products.UserRoles.Forms.ViewModel as URF
import App.Products.UserRoles.Forms.Update as URF
import App.Products.UserRoles.Messages as UR
import App.Products.UserRoles.Index.ViewModel        exposing (UserRolesView)
import App.Products.UserRoles.Requests               exposing (getUserRolesList, removeUserRole)
import App.Products.UserRoles.UserRole    as UR
import Data.External                                 exposing (External(..))
import Debug                                         exposing (crash)

update : UR.Msg -> UserRolesView -> AppConfig -> (UserRolesView, Cmd UR.Msg)
update action userRolesView appConfig =
  case action of
    UR.UpdateUserRoles userRolesResult ->
      case userRolesResult of
        Ok userRoleList ->
          let product           = userRolesView.product
              userRoleForm      = userRolesView.userRoleForm
              updatedProduct    = { product | userRoles = Loaded userRoleList }
              newUserRoleForm = Maybe.map2 URF.setProduct userRoleForm (Just updatedProduct)
              newView = { userRolesView |
                          product = updatedProduct
                        , userRoleForm = newUserRoleForm
                        }
          in (newView, Cmd.none)
        Err _ ->
          crash "Something went wrong!"

    UR.UserRoleAdded userRole ->
      (userRolesView, getUserRolesList appConfig userRolesView.product)

    UR.UserRoleUpdated userRole ->
      (userRolesView, getUserRolesList appConfig userRolesView.product)

    UR.ShowCreateUserRoleForm ->
      let product = userRolesView.product
          newForm = URF.init product UR.init URF.Create
      in
        ({ userRolesView | userRoleForm = Just newForm }, Cmd.none)

    UR.ShowEditUserRoleForm userRole ->
      let product = userRolesView.product
          newForm = URF.init product userRole URF.Edit
      in
        ({ userRolesView | userRoleForm = Just newForm }, Cmd.none)

    UR.HideUserRoleForm ->
      ({ userRolesView | userRoleForm = Nothing }, Cmd.none)

    UR.SearchFeatures searchQuery -> (userRolesView, Cmd.none)

    UR.RemoveUserRole userRole ->
      (,)
      userRolesView
      (removeUserRole appConfig userRolesView.product userRole)

    UR.UserRoleRemoved result ->
      -- This always results in an error, even with a 200 response
      -- because Elm cannot parse an empty response body.
      -- We can make this better, however.
      -- see: https://github.com/evancz/elm-http/issues/5
      case result of
        Ok a ->
          (,)
          userRolesView
          (getUserRolesList appConfig userRolesView.product)
        Err err ->
          (,)
          userRolesView
          (getUserRolesList appConfig userRolesView.product)

    _ ->
      case userRolesView.userRoleForm of
        Nothing -> (userRolesView, Cmd.none)
        Just userRoleForm ->
          let (dtForm, dtFormFx) = URF.update action userRoleForm appConfig
          in
            ( { userRolesView | userRoleForm = Just dtForm }
            , dtFormFx
            )
