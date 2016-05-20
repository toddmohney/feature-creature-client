module App.Products.UserRoles.Requests exposing
 ( createUserRole
 , editUserRole
 , getUserRolesList
 , removeUserRole
 )

import App.AppConfig                   exposing (..)
import App.Products.UserRoles.UserRole exposing (UserRole)
import App.Products.Product            exposing (Product)
import CoreExtensions.Maybe            exposing (fromJust)
import Http                            exposing (Error, Request)
import Json.Encode
import Json.Decode as Json             exposing ((:=))
import Task                            exposing (Task)
import Utils.Http


type Msg = FetchUserRolesSucceeded (List UserRole)
         | FetchUserRolesFailed Error
         | CreateUserRoleSucceeded UserRole
         | CreateUserRoleFailed Error
         | UpdateUserRoleSucceeded UserRole
         | UpdateUserRoleFailed Error
         | DeleteUserRoleSucceeded UserRole
         | DeleteUserRoleFailed Error

getUserRolesList : AppConfig -> Product -> Cmd Msg
getUserRolesList appConfig product =
  let successMsg = FetchUserRolesSucceeded
      failureMsg = FetchUserRolesFailed
      url = userRolesUrl appConfig product
      request = Http.get parseUserRoles url
  in
    Task.perform failureMsg successMsg request

createUserRole : AppConfig -> Product -> UserRole -> Cmd Msg
createUserRole appConfig product userRole =
  let successMsg = CreateUserRoleSucceeded
      failureMsg = CreateUserRoleFailed
      request = createUserRoleRequest appConfig product userRole
  in
    Task.perform failureMsg successMsg ((Http.send Http.defaultSettings request) |> Http.fromJson parseUserRole)

editUserRole : AppConfig
            -> Product
            -> UserRole
            -> Cmd Msg
editUserRole appConfig product userRole =
  let successMsg = UpdateUserRoleSucceeded
      failureMsg = UpdateUserRoleFailed
      request = editUserRoleRequest appConfig product userRole
  in
    Task.perform failureMsg successMsg (Http.send Http.defaultSettings request |> Http.fromJson parseUserRole)

removeUserRole : AppConfig
              -> Product
              -> UserRole
              -> Cmd Msg
removeUserRole appConfig product userRole =
  let successMsg = DeleteUserRoleSucceeded
      failureMsg = DeleteUserRoleFailed
      request = removeUserRoleRequest appConfig product userRole
  in
    Task.perform failureMsg successMsg (Http.send Http.defaultSettings request |> Http.fromJson (Json.succeed userRole))

removeUserRoleRequest : AppConfig -> Product -> UserRole -> Request
removeUserRoleRequest appConfig product userRole =
  Utils.Http.jsonDeleteRequest
    <| userRoleUrl appConfig product userRole

userRolesUrl : AppConfig -> Product -> String
userRolesUrl appConfig prod =
  appConfig.apiPath
  ++ "/products/"
  ++ (toString prod.id)
  ++ "/user-roles"

userRoleUrl : AppConfig -> Product -> UserRole -> String
userRoleUrl appConfig prod userRole =
  appConfig.apiPath
  ++ "/products/"
  ++ (toString prod.id)
  ++ "/user-roles/"
  ++ (toString (fromJust userRole.id))

createUserRoleRequest : AppConfig -> Product -> UserRole -> Request
createUserRoleRequest appConfig product userRole =
  Utils.Http.jsonPostRequest
    (userRolesUrl appConfig product)
    (encodeUserRole userRole)

editUserRoleRequest : AppConfig -> Product -> UserRole -> Request
editUserRoleRequest appConfig product userRole =
  Utils.Http.jsonPutRequest
    (userRoleUrl appConfig product userRole)
    (encodeUserRole userRole)

encodeUserRole : UserRole -> String
encodeUserRole userRole =
  case userRole.id of
    Nothing -> encodeWithoutId userRole
    Just id -> encodeWithId userRole

encodeWithoutId : UserRole -> String
encodeWithoutId userRole =
  Json.Encode.encode 0
    <| Json.Encode.object
        [ ("title",       Json.Encode.string userRole.title)
        , ("description", Json.Encode.string userRole.description)
        ]

encodeWithId : UserRole -> String
encodeWithId userRole =
  Json.Encode.encode 0
    <| Json.Encode.object
        [ ("id",          Json.Encode.int (fromJust userRole.id))
        , ("title",       Json.Encode.string userRole.title)
        , ("description", Json.Encode.string userRole.description)
        ]

parseUserRoles : Json.Decoder (List UserRole)
parseUserRoles = parseUserRole |> Json.list

parseUserRole : Json.Decoder UserRole
parseUserRole =
  Json.object3 UserRole
    (Json.maybe ("id" := Json.int))
    ("title"         := Json.string)
    ("description"   := Json.string)

