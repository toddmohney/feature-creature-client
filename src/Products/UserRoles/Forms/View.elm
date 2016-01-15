module Products.UserRoles.Forms.View
  ( view ) where

import Html                              exposing (Html)
import Html.Attributes                    exposing (href)
import Html.Events                        exposing (onClick)
import Products.UserRoles.Forms.Actions   exposing (..)
import Products.UserRoles.Forms.ViewModel exposing (UserRoleForm)
import UI.App.Components.Panels    as UI
import UI.App.Primitives.Forms     as UI

view : Signal.Address Action -> UserRoleForm -> Html
view address userRoleForm =
  if userRoleForm.userRoleFormVisible
    then
      let userRoleFormHtml = renderUserRoleForm address userRoleForm
      in Html.div [] [ userRoleFormHtml ]
    else
      Html.a
      [ href "#", onClick address ShowUserRoleForm ]
      [ Html.text "Create User Role" ]

renderUserRoleForm : Signal.Address Action -> UserRoleForm -> Html
renderUserRoleForm address userRoleForm =
  let headingContent = Html.text "Create A New User Role"
      bodyContent    = renderForm address userRoleForm
  in UI.panelWithHeading headingContent bodyContent

renderForm : Signal.Address Action -> UserRoleForm -> Html
renderForm address userRoleForm =
  Html.div
    []
    [ UI.input address userRoleForm.titleField
    , UI.textarea address userRoleForm.descriptionField
    , UI.cancelButton (onClick address HideUserRoleForm)
    , UI.submitButton (onClick address SubmitUserRoleForm)
    ]
