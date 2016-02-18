module App.Products.UserRoles.Forms.View
  ( view
  ) where

import App.Products.UserRoles.Forms.Actions   exposing (..)
import App.Products.UserRoles.Forms.ViewModel exposing (UserRoleForm, FormMode(..))
import Data.Actions                           exposing (..)
import Html                                   exposing (Html)
import Html.Attributes                        exposing (classList, href, style)
import Html.Events                            exposing (onClick)
import UI.App.Components.Containers as UI
import UI.App.Components.Panels    as UI
import UI.App.Primitives.Forms     as UI

view : Signal.Address Action -> ForwardedAction a -> UserRoleForm -> Html
view address hideAction userRoleForm =
  let userRoleFormHtml = formContainer <| renderUserRoleForm address hideAction userRoleForm
  in
    UI.clearfix [] [ userRoleFormHtml ]

formContainer : Html -> Html
formContainer content =
  Html.div
    [ classList [ ("pull-right", True) ]
    , style [ ("width", "50%") ]
    ]
    [ content ]

renderUserRoleForm : Signal.Address Action -> ForwardedAction a -> UserRoleForm -> Html
renderUserRoleForm address hideAction userRoleForm =
  let bodyContent    = renderForm address hideAction userRoleForm
  in UI.panelWithHeading (headingContent userRoleForm.formMode) bodyContent

headingContent : FormMode -> Html
headingContent formMode =
  case formMode of
    Create -> Html.text "Create A New User Role"
    Edit   -> Html.text "Edit User Role"

renderForm : Signal.Address Action -> ForwardedAction a -> UserRoleForm -> Html
renderForm address hideAction userRoleForm =
  Html.div
    []
    [ UI.input address userRoleForm.titleField
    , UI.textarea address userRoleForm.descriptionField
    , UI.cancelButton (onClick hideAction.address hideAction.action)
    , UI.submitButton (onClick address SubmitUserRoleForm)
    ]
