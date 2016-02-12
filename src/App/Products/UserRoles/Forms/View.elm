module App.Products.UserRoles.Forms.View
  ( view ) where

import Html                                   exposing (Html)
import Html.Attributes                        exposing (classList, href, style)
import Html.Events                            exposing (onClick)
import App.Products.UserRoles.Forms.Actions   exposing (..)
import App.Products.UserRoles.Forms.ViewModel exposing (UserRoleForm)
import UI.App.Components.Panels    as UI
import UI.App.Primitives.Forms     as UI

view : Signal.Address Action -> UserRoleForm -> Html
view address userRoleForm =
  case userRoleForm.userRoleFormVisible of
    True ->
      let userRoleFormHtml = renderUserRoleForm address userRoleForm
      in
        Html.div
        [ classList [ ("clearfix", True) ] ]
        [ Html.div
          [ classList [ ("pull-right", True) ]
          , style [ ("width", "50%") ]
          ]
          [ userRoleFormHtml ]
        ]
    False ->
      Html.div
      [ classList [ ("clearfix", True), ("fc-margin--bottom--medium", True) ] ]
      [ renderFormButton address ]

renderFormButton : Signal.Address Action -> Html
renderFormButton address =
  Html.a
  [ href "#", onClick address ShowUserRoleForm
  , classList [ ("pull-right", True)
              , ("btn", True)
              , ("btn-primary", True)
              ]
  ]
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
