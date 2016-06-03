module App.Products.UserRoles.Forms.View exposing ( view )

import App.Products.UserRoles.Messages        exposing (..)
import App.Products.UserRoles.Forms.ViewModel exposing (UserRoleForm, FormMode(..))
import Data.Msgs                           exposing (..)
import Html                                   exposing (Html)
import Html.Attributes                        exposing (classList, href, style)
import Html.Events                            exposing (onClick)
import UI.App.Components.Containers as UI
import UI.App.Components.Panels    as UI
import UI.App.Primitives.Forms     as UI

view : ForwardedMsg Msg -> UserRoleForm -> Html Msg
view hideMsg userRoleForm =
  let userRoleFormHtml = formContainer <| renderUserRoleForm hideMsg userRoleForm
  in
    UI.clearfix [] [ userRoleFormHtml ]

formContainer : Html a -> Html a
formContainer content =
  Html.div
    [ classList [ ("pull-right", True) ]
    , style [ ("width", "50%") ]
    ]
    [ content ]

renderUserRoleForm : ForwardedMsg Msg -> UserRoleForm -> Html Msg
renderUserRoleForm hideMsg userRoleForm =
  let bodyContent    = renderForm hideMsg userRoleForm
  in UI.panelWithHeading (headingContent userRoleForm.formMode) bodyContent

headingContent : FormMode -> Html a
headingContent formMode =
  case formMode of
    Create -> Html.text "Create A New User Role"
    Edit   -> Html.text "Edit User Role"

renderForm : ForwardedMsg Msg -> UserRoleForm -> Html Msg
renderForm hideMsg userRoleForm =
  Html.div
    []
    [ UI.input userRoleForm.titleField
    , UI.textarea userRoleForm.descriptionField
    , UI.cancelButton (onClick hideMsg.msg)
    , UI.submitButton (onClick SubmitUserRoleForm)
    ]
