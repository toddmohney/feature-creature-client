module App.Products.UserRoles.Forms.View exposing ( view )

import App.Products.UserRoles.Forms.Actions   exposing (..)
import App.Products.UserRoles.Forms.ViewModel exposing (UserRoleForm, FormMode(..))
import Data.Actions                           exposing (..)
import Html                                   exposing (Html)
import Html.Attributes                        exposing (classList, href, style)
import Html.Events                            exposing (onClick)
import UI.App.Components.Containers as UI
import UI.App.Components.Panels    as UI
import UI.App.Primitives.Forms     as UI

view : ForwardedAction Action -> UserRoleForm -> Html Action
view hideAction userRoleForm =
  let userRoleFormHtml = formContainer <| renderUserRoleForm hideAction userRoleForm
  in
    UI.clearfix [] [ userRoleFormHtml ]

formContainer : Html a -> Html a
formContainer content =
  Html.div
    [ classList [ ("pull-right", True) ]
    , style [ ("width", "50%") ]
    ]
    [ content ]

renderUserRoleForm : ForwardedAction Action -> UserRoleForm -> Html Action
renderUserRoleForm hideAction userRoleForm =
  let bodyContent    = renderForm hideAction userRoleForm
  in UI.panelWithHeading (headingContent userRoleForm.formMode) bodyContent

headingContent : FormMode -> Html a
headingContent formMode =
  case formMode of
    Create -> Html.text "Create A New User Role"
    Edit   -> Html.text "Edit User Role"

renderForm : ForwardedAction Action -> UserRoleForm -> Html Action
renderForm hideAction userRoleForm =
  Html.div
    []
    [ UI.input userRoleForm.titleField
    , UI.textarea userRoleForm.descriptionField
    , UI.cancelButton (onClick hideAction.action)
    , UI.submitButton (onClick SubmitUserRoleForm)
    ]
