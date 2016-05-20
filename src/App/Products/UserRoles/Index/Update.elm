module App.Products.UserRoles.Index.Update exposing ( update )

import App.AppConfig                                 exposing (..)
import App.Products.UserRoles.Forms.Actions as FormActions
import App.Products.UserRoles.Forms.ViewModel as URF
import App.Products.UserRoles.Forms.Update as URF
import App.Products.UserRoles.Index.Actions as Actions
import App.Products.UserRoles.Index.ViewModel        exposing (UserRolesView)
import App.Products.UserRoles.Requests               exposing (getUserRolesList, removeUserRole)
import App.Products.UserRoles.UserRole    as UR
import Data.External                                 exposing (External(..))
import Debug                                         exposing (crash)

update : Actions.UserRoleAction -> UserRolesView -> AppConfig -> (UserRolesView, Effects Actions.UserRoleAction)
update action userRolesView appConfig =
  case action of
    Actions.UpdateUserRoles userRolesResult ->
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
          in (newView, Effects.none)
        Err _ ->
          crash "Something went wrong!"

    Actions.UserRoleFormAction dtFormAction ->
      case dtFormAction of
        FormActions.UserRoleAdded userRole   -> (userRolesView, getUserRolesList appConfig userRolesView.product Actions.UpdateUserRoles)

        FormActions.UserRoleUpdated userRole -> (userRolesView, getUserRolesList appConfig userRolesView.product Actions.UpdateUserRoles)

        _ ->
          case userRolesView.userRoleForm of
            Nothing             -> (userRolesView, Effects.none)
            Just userRoleForm ->
              let (dtForm, dtFormFx) = URF.update dtFormAction userRoleForm appConfig
              in
                ( { userRolesView | userRoleForm = Just dtForm }
                , Effects.map Actions.UserRoleFormAction dtFormFx
                )

    Actions.ShowCreateUserRoleForm ->
      let product = userRolesView.product
          newForm = URF.init product UR.init URF.Create
      in
        ({ userRolesView | userRoleForm = Just newForm }, Effects.none)

    Actions.ShowEditUserRoleForm userRole ->
      let product = userRolesView.product
          newForm = URF.init product userRole URF.Edit
      in
        ({ userRolesView | userRoleForm = Just newForm }, Effects.none)

    Actions.HideUserRoleForm ->
      ({ userRolesView | userRoleForm = Nothing }, Effects.none)

    Actions.SearchFeatures searchQuery -> (userRolesView, Effects.none)

    Actions.RemoveUserRole userRole ->
      (,)
      userRolesView
      (removeUserRole appConfig userRolesView.product userRole Actions.UserRoleRemoved)

    Actions.UserRoleRemoved result ->
      -- This always results in an error, even with a 200 response
      -- because Elm cannot parse an empty response body.
      -- We can make this better, however.
      -- see: https://github.com/evancz/elm-http/issues/5
      case result of
        Ok a ->
          (,)
          userRolesView
          (getUserRolesList appConfig userRolesView.product Actions.UpdateUserRoles)
        Err err ->
          (,)
          userRolesView
          (getUserRolesList appConfig userRolesView.product Actions.UpdateUserRoles)
