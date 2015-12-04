module Products.UserRoles.Form where

import Debug                             exposing (crash)
import Effects                           exposing (Effects)
import Html                              exposing (Html)
import Html.Attributes                   exposing (href)
import Html.Events                       exposing (onClick)
import Http                              exposing (Error)
import Products.UserRoles.UserRole as UR exposing (UserRole)
import Products.Product                  exposing (Product)
import Task                              exposing (Task)
import UI.App.Components.Panels    as UI exposing (..)
import UI.App.Primitives.Forms     as UI exposing (..)
import Utils.Http

type alias UserRoleForm =
  { product : Product
  , userRoleFormVisible  : Bool
  , newUserRole          : UserRole
  , titleField           : InputField Action
  , descriptionField     : InputField Action
  }

type Action = AddUserRole (Result Error UserRole)
            | ShowUserRoleForm
            | HideUserRoleForm
            | SubmitUserRoleForm
            | SetUserRoleTitle String
            | SetUserRoleDescription String

init : Product -> UserRoleForm
init prod =
  { product              = prod
  , userRoleFormVisible  = False
  , newUserRole          = UR.init
  , titleField           = defaultTitleField
  , descriptionField     = defaultDescriptionField
  }

defaultTitleField : InputField Action
defaultTitleField =
  { inputName = "userRoleTitle"
  , labelContent = (Html.text "Title")
  , inputParser = SetUserRoleTitle
  , validationErrors = []
  }

defaultDescriptionField : InputField Action
defaultDescriptionField =
  { inputName = "userRoleDescription"
  , labelContent = (Html.text "Description")
  , inputParser = SetUserRoleDescription
  , validationErrors = []
  }

update : Action -> UserRoleForm -> (UserRoleForm, Effects Action)
update action userRoleForm =
  case action of
    AddUserRole userRoleResult ->
      case userRoleResult of
        Ok userRole ->
          let prod             = userRoleForm.product
              newUserRolesList = userRole :: prod.userRoles
              updatedProduct   = { prod | userRoles = newUserRolesList }
              newView          = { userRoleForm | product = updatedProduct }
          in (newView, Effects.none)
        Err _ -> crash "Something went wrong!"

    ShowUserRoleForm ->
      ({ userRoleForm | userRoleFormVisible = True }, Effects.none)

    HideUserRoleForm ->
      ({ userRoleForm | userRoleFormVisible = False }, Effects.none)

    SetUserRoleTitle newTitle ->
      let newUserRole     = userRoleForm.newUserRole
          updatedUserRole = { newUserRole | title    = newTitle }
      in ({ userRoleForm | newUserRole = updatedUserRole }, Effects.none)

    SetUserRoleDescription newDescription ->
      let newUserRole     = userRoleForm.newUserRole
          updatedUserRole = { newUserRole | description = newDescription }
      in ({ userRoleForm | newUserRole = updatedUserRole }, Effects.none)

    SubmitUserRoleForm ->
      let newUserRoleForm = validateForm userRoleForm
      in
         case hasErrors newUserRoleForm of
           True ->
             ( newUserRoleForm
             , Effects.none
             )
           False ->
             ( newUserRoleForm
             , createUserRole (userRolesUrl newUserRoleForm.product) newUserRoleForm.newUserRole
             )

validateForm : UserRoleForm -> UserRoleForm
validateForm form =
  let userRole            = form.newUserRole
      titleField          = form.titleField
      descriptionField    = form.descriptionField
      newTitleField       = { titleField | validationErrors       = validateTitle userRole.title }
      newDescriptionField = { descriptionField | validationErrors = validateDescription userRole.description }
  in
     { form | titleField = newTitleField
            , descriptionField = newDescriptionField
     }

validateTitle : String -> (List String)
validateTitle = requiredStringFieldValidation

validateDescription : String -> (List String)
validateDescription = requiredStringFieldValidation

hasErrors : UserRoleForm -> Bool
hasErrors = not << isSubmittable

isSubmittable : UserRoleForm -> Bool
isSubmittable userRoleForm =
  let titleField       = userRoleForm.titleField
      descriptionField = userRoleForm.descriptionField
  in
     (List.isEmpty titleField.validationErrors)
     && (List.isEmpty descriptionField.validationErrors)

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
    [ UI.input' address userRoleForm.titleField
    , UI.textarea' address userRoleForm.descriptionField
    , UI.cancelButton (onClick address HideUserRoleForm)
    , UI.submitButton (onClick address SubmitUserRoleForm)
    ]

userRolesUrl : Product -> String
userRolesUrl prod = "http://localhost:8081/products/" ++ (toString prod.id) ++ "/user-roles"

createUserRole : String -> UserRole -> Effects Action
createUserRole url userRole =
  let request = Utils.Http.jsonPostRequest url (UR.encodeUserRole userRole)
  in Http.send Http.defaultSettings request
     |> Http.fromJson UR.parseUserRole
     |> Task.toResult
     |> Task.map AddUserRole
     |> Effects.task
