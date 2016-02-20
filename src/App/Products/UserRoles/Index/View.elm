module App.Products.UserRoles.Index.View
  ( view
  ) where

import App.Products.UserRoles.Index.Actions as Actions exposing (UserRoleAction(..))
import App.Products.UserRoles.Index.ViewModel          exposing (UserRolesView)
import App.Products.UserRoles.Forms.View as URF
import App.Products.UserRoles.Forms.ViewModel          exposing (UserRoleForm)
import App.Products.UserRoles.UserRole as UR           exposing (UserRole, toSearchQuery)
import Data.Actions                                    exposing (..)
import Data.External                                   exposing (External(..))
import Html                                            exposing (Html)
import Html.Events                                     exposing (onClick)
import Html.Attributes as Html                         exposing (class, href)
import UI.App.Components.Containers       as UI
import UI.App.Components.Panels as UI
import UI.Bootstrap.Components.Glyphicons as Glyph
import UI.Bootstrap.Responsiveness as UI                exposing (ScreenSize(..))

view : Signal.Address UserRoleAction -> UserRolesView -> Html
view address userRolesView =
  let userRoles =
    case userRolesView.product.userRoles of
      Loaded dts -> dts
      _          -> []
  in
    Html.div
    []
    [ userRoleFormUI address userRolesView.userRoleForm
    , Html.div
        [ Html.classList [ ("row", True) ] ]
        (renderUserRoles address userRoles [])
    ]

userRoleFormUI : Signal.Address UserRoleAction -> Maybe UserRoleForm -> Html
userRoleFormUI address userRoleForm =
  case userRoleForm of
    Nothing ->
      createUserRoleUI address
    Just userRoleForm ->
      let forwardedAddress  = Signal.forwardTo address Actions.UserRoleFormAction
          hideFormAction = ForwardedAction address Actions.HideUserRoleForm
      in
        URF.view forwardedAddress hideFormAction userRoleForm

createUserRoleUI : Signal.Address UserRoleAction -> Html
createUserRoleUI address =
  UI.clearfix
  [("fc-margin--bottom--medium", True)]
  [ createUserRoleButton address ]

createUserRoleButton : Signal.Address UserRoleAction -> Html
createUserRoleButton address =
  Html.a
  [ href "#", onClick address Actions.ShowCreateUserRoleForm
  , Html.classList [ ("pull-right", True)
                   , ("btn", True)
                   , ("btn-primary", True)
                   ]
  ]
  [ Html.text "Create Domain Term" ]

renderUserRoles : Signal.Address UserRoleAction -> List UserRole -> List Html -> List Html
renderUserRoles address userRoles collection =
  case userRoles of
    []       -> collection
    x::[]    ->
      collection
        ++ [(renderUserRole address x)]
    x::y::[] ->
      collection
        ++ [(renderUserRole address x)]
        ++ [(renderUserRole address y)]
        ++ [UI.colResetBlock Medium]
    x::y::z::xs ->
      renderUserRoles address xs
        <| collection
          ++ [(renderUserRole address x)]
          ++ [(renderUserRole address y)]
          ++ [UI.colResetBlock Medium]
          ++ [(renderUserRole address z)]
          ++ [UI.colResetBlock Large]

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
  let linkAction = ShowEditUserRoleForm userRole
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
