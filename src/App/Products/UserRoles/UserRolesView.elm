module App.Products.UserRoles.UserRolesView where

import Debug                                         exposing (crash)
import Effects                                       exposing (Effects)
import Html                                          exposing (Html)
import Html.Events                                   exposing (onClick)
import Html.Attributes                               exposing (class, href)
import Http                                          exposing (Error)
import App.Products.UserRoles.UserRole as UR         exposing (UserRole, toSearchQuery)
import App.Products.UserRoles.Forms.Actions as URF
import App.Products.UserRoles.Forms.ViewModel as URF
import App.Products.UserRoles.Forms.Update as URF
import App.Products.UserRoles.Forms.View as URF
import App.Products.Product                          exposing (Product)
import App.Search.Types as Search
import Task                                          exposing (Task)
import UI.App.Components.Panels as UI

type alias UserRolesView =
  { product        : Product
  , userRoleForm : URF.UserRoleForm
  }

type Action = UpdateUserRoles (Result Error (List UserRole))
            | UserRoleFormAction URF.Action
            | SearchFeatures Search.Query

init : Product -> (UserRolesView, Effects Action)
init prod =
  let effects = getUserRolesList (userRolesUrl prod)
  in ( { product = prod
       , userRoleForm = URF.init prod
       }
     , effects
     )

update : Action -> UserRolesView -> (UserRolesView, Effects Action)
update action userRolesView =
  case action of
    -- This is smelly. The UserRoleFrom is allowed to update the Product,
    -- so we need to update both this model and the form model.
    -- Try to refactor to let the updates flow in One Direction
    UpdateUserRoles userRolesResult ->
      case userRolesResult of
        Ok userRoleList ->
          let prod = userRolesView.product
              updatedProduct = { prod | userRoles = userRoleList }
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
      let (dtForm, dtFormFx) = URF.update dtFormAction userRolesView.userRoleForm
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


view : Signal.Address Action -> UserRolesView -> Html
view address userRolesView =
  let userRoles = userRolesView.product.userRoles
      forwardedAddress = (Signal.forwardTo address UserRoleFormAction)
      newUserRoleForm = URF.view forwardedAddress userRolesView.userRoleForm
  in Html.div [] (newUserRoleForm :: (List.map (renderUserRole address) userRoles))

getUserRolesList : String -> Effects Action
getUserRolesList url =
  Http.get UR.parseUserRoles url
   |> Task.toResult
   |> Task.map UpdateUserRoles
   |> Effects.task

renderUserRole : Signal.Address Action -> UserRole -> Html
renderUserRole address userRole =
  let userRoleName = Html.div [ class "pull-left" ] [ Html.text userRole.title ]
      linkAction     = SearchFeatures (toSearchQuery userRole)
      featureLink    = Html.a [ href "#", onClick address linkAction ] [ Html.text "View features" ]
      featureLinkContainer = Html.div [ class "pull-right" ] [ featureLink ]
      headingContent = Html.div [ class "clearfix" ] [ userRoleName, featureLinkContainer ]
  in UI.panelWithHeading headingContent (Html.text userRole.description)

userRolesUrl : Product -> String
userRolesUrl prod = "http://localhost:8081/products/" ++ (toString prod.id) ++ "/user-roles"
