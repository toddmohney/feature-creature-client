module App.Products.UserRoles.Index.View where

import App.Products.UserRoles.Actions                exposing (Action(..))
import App.Products.UserRoles.Forms.View as URF
import App.Products.UserRoles.Index.ViewModel        exposing (UserRolesView)
import App.Products.UserRoles.UserRole as UR         exposing (UserRole, toSearchQuery)
import Data.External                                 exposing (External(..))
import Html                                          exposing (Html)
import Html.Events                                   exposing (onClick)
import Html.Attributes                               exposing (class, href)
import UI.App.Components.Panels as UI

view : Signal.Address Action -> UserRolesView -> Html
view address userRolesView =
  let forwardedAddress = (Signal.forwardTo address UserRoleFormAction)
      newUserRoleForm = URF.view forwardedAddress userRolesView.userRoleForm
      userRoles = case userRolesView.product.userRoles of
        Loaded urs -> urs
        _          -> []
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

