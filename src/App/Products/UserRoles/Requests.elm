module App.Products.UserRoles.Requests exposing
 ( createUserRole
 , editUserRole
 , getUserRolesList
 , removeUserRole
 )

import App.AppConfig                   exposing (..)
import App.Products.UserRoles.UserRole exposing (UserRole)
import App.Products.UserRoles.Messages exposing (..)
import App.Products.Product            exposing (Product)
import CoreExtensions.Maybe            exposing (fromJust)
import Http                            exposing (Error, Request)
import Json.Encode
import Json.Decode as Json             exposing ((:=))
import Task                            exposing (Task)
import Utils.Http

getUserRolesList : AppConfig
                -> Product
                -> Cmd Msg
getUserRolesList appConfig product =
  userRolesUrl appConfig product
    |> Http.get parseUserRoles
    |> Task.perform FetchUserRolesFailed FetchUserRolesSucceeded

createUserRole : AppConfig
              -> Product
              -> UserRole
              -> Cmd Msg
createUserRole appConfig product userRole =
  createUserRoleRequest appConfig product userRole
    |> Http.send Http.defaultSettings
    |> Http.fromJson parseUserRole
    |> Task.perform CreateUserRoleFailed CreateUserRoleSucceeded

editUserRole : AppConfig
            -> Product
            -> UserRole
            -> Cmd Msg
editUserRole appConfig product userRole =
  editUserRoleRequest appConfig product userRole
    |> Http.send Http.defaultSettings
    |> Http.fromJson parseUserRole
    |> Task.perform UpdateUserRoleFailed UpdateUserRoleSucceeded

removeUserRole : AppConfig
              -> Product
              -> UserRole
              -> Cmd Msg
removeUserRole appConfig product userRole =
  removeUserRoleRequest appConfig product userRole
    |> Http.send Http.defaultSettings
    |> Http.fromJson (Json.succeed userRole)
    |> Task.perform DeleteUserRoleFailed DeleteUserRoleSucceeded

removeUserRoleRequest : AppConfig -> Product -> UserRole -> Request
removeUserRoleRequest appConfig product userRole =
  userRoleUrl appConfig product userRole
    |> Utils.Http.jsonDeleteRequest

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

