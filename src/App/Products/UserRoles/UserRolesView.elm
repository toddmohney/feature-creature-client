module App.Products.UserRoles.UserRolesView where

import App.AppConfig                                 exposing (..)
import App.Products.UserRoles.Actions                exposing (Action(..))
import App.Products.UserRoles.Forms.ViewModel as URF
import App.Products.UserRoles.Forms.Update as URF
import App.Products.UserRoles.Forms.View as URF
import App.Products.UserRoles.Requests               exposing (getUserRolesList)
import App.Products.UserRoles.UserRole as UR         exposing (UserRole, toSearchQuery)
import App.Products.Product                          exposing (Product)
import Debug                                         exposing (crash)
import Effects                                       exposing (Effects)
import Html                                          exposing (Html)
import Html.Events                                   exposing (onClick)
import Html.Attributes                               exposing (class, href)
import UI.App.Components.Panels as UI

type alias UserRolesView =
  { product        : Product
  , userRoleForm : URF.UserRoleForm
  }

init : Product -> AppConfig -> (UserRolesView, Effects Action)
init prod appConfig =
  let effects = getUserRolesList appConfig prod UpdateUserRoles
  in (,)
     { product = prod
     , userRoleForm = URF.init prod
     }
     effects

update : Action -> UserRolesView -> AppConfig -> (UserRolesView, Effects Action)
update action userRolesView appConfig =
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

view : Signal.Address Action -> UserRolesView -> Html
view address userRolesView =
  let userRoles = userRolesView.product.userRoles
      forwardedAddress = (Signal.forwardTo address UserRoleFormAction)
      newUserRoleForm = URF.view forwardedAddress userRolesView.userRoleForm
  in
    Html.div [] (newUserRoleForm :: (List.map (renderUserRole address) userRoles))

renderUserRole : Signal.Address Action -> UserRole -> Html
renderUserRole address userRole =
  let userRoleName = Html.div [ class "pull-left" ] [ Html.text userRole.title ]
      linkAction     = SearchFeatures (toSearchQuery userRole)
      featureLink    = Html.a [ href "#", onClick address linkAction ] [ Html.text "View features" ]
      featureLinkContainer = Html.div [ class "pull-right" ] [ featureLink ]
      headingContent = Html.div [ class "clearfix" ] [ userRoleName, featureLinkContainer ]
  in
    UI.panelWithHeading headingContent (Html.text userRole.description)
