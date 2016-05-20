module App.Products.UserRoles.Index.View exposing ( view )

-- import App.Products.UserRoles.Index.Actions as Actions exposing (UserRoleAction(..))
import App.Products.UserRoles.Index.ViewModel          exposing (UserRolesView)
import App.Products.UserRoles.Forms.View as URF
import App.Products.UserRoles.Forms.ViewModel          exposing (UserRoleForm)
import App.Products.UserRoles.Messages                 exposing (Msg(..))
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

view : UserRolesView -> Html Msg
view userRolesView =
  let userRoles =
    case userRolesView.product.userRoles of
      Loaded dts -> dts
      _          -> []
  in
    Html.div
    []
    [ userRoleFormUI userRolesView.userRoleForm
    , Html.div
        [ Html.classList [ ("row", True) ] ]
        (renderUserRoles userRoles [])
    ]

userRoleFormUI : Maybe UserRoleForm -> Html Msg
userRoleFormUI userRoleForm =
  case userRoleForm of
    Nothing ->
      createUserRoleUI
    Just userRoleForm ->
      let hideFormAction = ForwardedAction HideUserRoleForm
      in
        URF.view hideFormAction userRoleForm

createUserRoleUI : Html Msg
createUserRoleUI =
  UI.clearfix
  [("fc-margin--bottom--medium", True)]
  [ createUserRoleButton ]

createUserRoleButton : Html Msg
createUserRoleButton =
  Html.a
  [ href "#", onClick ShowCreateUserRoleForm
  , Html.classList [ ("pull-right", True)
                   , ("btn", True)
                   , ("btn-primary", True)
                   ]
  ]
  [ Html.text "Create User Role" ]

renderUserRoles : List UserRole -> List (Html Msg) -> List (Html Msg)
renderUserRoles userRoles collection =
  case userRoles of
    []       -> collection
    x::[]    ->
      collection
        ++ [(renderUserRole x)]
    x::y::[] ->
      collection
        ++ [(renderUserRole x)]
        ++ [(renderUserRole y)]
        ++ [UI.colResetBlock Medium]
    x::y::z::xs ->
      renderUserRoles xs
        <| collection
          ++ [(renderUserRole x)]
          ++ [(renderUserRole y)]
          ++ [UI.colResetBlock Medium]
          ++ [(renderUserRole z)]
          ++ [UI.colResetBlock Large]

renderUserRole : UserRole -> Html Msg
renderUserRole userRole =
  let searchFeaturesUI   = searchFeaturesLink userRole
      editUserRoleUI   = editUserRoleLink userRole
      removeUserRoleUI = removeUserRoleLink userRole
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

searchFeaturesLink : UserRole -> Html Msg
searchFeaturesLink userRole =
  let linkAction = SearchFeatures (toSearchQuery userRole)
  in
    Html.a
    [ href "#", onClick linkAction ]
    [ Glyph.searchIcon ]

editUserRoleLink : UserRole -> Html Msg
editUserRoleLink userRole =
  let linkAction = ShowEditUserRoleForm userRole
  in
    Html.a
    [ href "#", onClick linkAction ]
    [ Glyph.editIcon ]

removeUserRoleLink : UserRole -> Html Msg
removeUserRoleLink userRole =
  let linkAction = RemoveUserRole userRole
  in
    Html.a
    [ href "#", onClick linkAction ]
    [ Glyph.removeIcon ]

-- inject panelHeaderActions
userRolePanelHeading : UserRole -> Html a -> Html a -> Html a -> Html a
userRolePanelHeading userRole searchFeaturesLink editUserRoleLink removeUserRoleLink =
  Html.div
  [ class "clearfix" ]
  [ panelHeaderInfo userRole
  , panelHeaderActions searchFeaturesLink editUserRoleLink removeUserRoleLink
  ]

panelHeaderActions : Html a -> Html a -> Html a -> Html a
panelHeaderActions searchFeaturesLink editUserRoleLink removeUserRoleLink =
  Html.div
  [ class "pull-right" ]
  [ searchFeaturesLink
  , editUserRoleLink
  , removeUserRoleLink
  ]

panelHeaderInfo : UserRole -> Html a
panelHeaderInfo userRole =
  Html.div
  [ class "pull-left" ]
  [ Html.text userRole.title ]
