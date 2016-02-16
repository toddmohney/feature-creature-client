module App.Products.UserRoles.Index.View where

import App.Products.UserRoles.Actions                exposing (UserRoleAction(..))
import App.Products.UserRoles.Forms.View as URF
import App.Products.UserRoles.Index.ViewModel        exposing (UserRolesView)
import App.Products.UserRoles.UserRole as UR         exposing (UserRole, toSearchQuery)
import Data.External                                 exposing (External(..))
import Html                                          exposing (Html)
import Html.Events                                   exposing (onClick)
import Html.Attributes as Html                       exposing (class, href)
import UI.App.Components.Panels as UI
import UI.Bootstrap.Components.Glyphicons as Glyph

view : Signal.Address UserRoleAction -> UserRolesView -> Html
view address userRolesView =
  let forwardedAddress = (Signal.forwardTo address UserRoleFormAction)
      newUserRoleForm  = URF.view forwardedAddress userRolesView.userRoleForm
      userRoles        = case userRolesView.product.userRoles of
                           Loaded urs -> urs
                           _          -> []
  in
    Html.div
      [ Html.classList [ ("row", True) ] ]
      (newUserRoleForm :: (List.map (renderUserRole address) userRoles))

renderUserRole : Signal.Address UserRoleAction -> UserRole -> Html
renderUserRole address userRole =
  let searchFeaturesUI   = searchFeaturesLink address userRole
      editUserRoleUI   = editUserRoleLink address userRole
      removeUserRoleUI = removeUserRoleLink address userRole
      responsiveClasses = Html.classList [ ("col-lg-4", True)
                                         , ("col-md-6", True)
                                         , ("col-sm-12", True)
                                         ]
  in
    Html.div
    [ responsiveClasses ]
    [ UI.panelWithHeading
        (userRolePanelHeading userRole searchFeaturesUI editUserRoleUI removeUserRoleUI)
        (Html.text userRole.description)
    ]

searchFeaturesLink : Signal.Address UserRoleAction -> UserRole -> Html
searchFeaturesLink address userRole =
  let linkAction = SearchFeatures (toSearchQuery userRole)
  in
    Html.a
    [ href "#", onClick address linkAction ]
    [ Glyph.searchIcon ]

editUserRoleLink : Signal.Address UserRoleAction -> UserRole -> Html
editUserRoleLink address userRole =
  let linkAction = EditUserRole userRole
  in
    Html.a
    [ href "#", onClick address linkAction ]
    [ Glyph.editIcon ]

removeUserRoleLink : Signal.Address UserRoleAction -> UserRole -> Html
removeUserRoleLink address userRole =
  let linkAction = RemoveUserRole userRole
  in
    Html.a
    [ href "#", onClick address linkAction ]
    [ Glyph.removeIcon ]

-- inject panelHeaderActions
userRolePanelHeading : UserRole -> Html -> Html -> Html -> Html
userRolePanelHeading userRole searchFeaturesLink editUserRoleLink removeUserRoleLink =
  Html.div
  [ class "clearfix" ]
  [ panelHeaderInfo userRole
  , panelHeaderActions searchFeaturesLink editUserRoleLink removeUserRoleLink
  ]

panelHeaderActions : Html -> Html -> Html -> Html
panelHeaderActions searchFeaturesLink editUserRoleLink removeUserRoleLink =
  Html.div
  [ class "pull-right" ]
  [ searchFeaturesLink
  , editUserRoleLink
  , removeUserRoleLink
  ]

panelHeaderInfo : UserRole -> Html
panelHeaderInfo userRole =
  Html.div
  [ class "pull-left" ]
  [ Html.text userRole.title ]

-- renderUserRole : Signal.Address Action -> UserRole -> Html
-- renderUserRole address userRole =
  -- let userRoleName = Html.div [ class "pull-left" ] [ Html.text userRole.title ]
      -- linkAction     = SearchFeatures (toSearchQuery userRole)
      -- featureLink    = Html.a [ href "#", onClick address linkAction ] [ Html.text "View features" ]
      -- featureLinkContainer = Html.div [ class "pull-right" ] [ featureLink ]
      -- headingContent = Html.div [ class "clearfix" ] [ userRoleName, featureLinkContainer ]
  -- in
    -- UI.panelWithHeading headingContent (Html.text userRole.description)

