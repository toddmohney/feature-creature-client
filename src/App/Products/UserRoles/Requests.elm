module App.Products.UserRoles.Requests
 ( createUserRole
 , getUserRolesList
 ) where

import App.AppConfig                                       exposing (..)
import App.Products.UserRoles.UserRole                     exposing (UserRole)
import App.Products.Product                                exposing (Product)
import Effects                                             exposing (Effects)
import Http                                                exposing (Error, Request)
import Json.Encode
import Json.Decode as Json exposing ((:=))
import Task                                                exposing (Task)
import Utils.Http

getUserRolesList : AppConfig -> Product -> (Result Error (List UserRole) -> a) -> Effects a
getUserRolesList appConfig product action =
  let url = userRolesUrl appConfig product
  in
    Http.get parseUserRoles url
      |> Task.toResult
      |> Task.map action
      |> Effects.task

createUserRole : AppConfig -> Product -> UserRole -> (Result Error UserRole -> a) -> Effects a
createUserRole appConfig product userRole action =
  let request = createUserRoleRequest appConfig product userRole
  in 
    Http.send Http.defaultSettings request
      |> Http.fromJson parseUserRole
      |> Task.toResult
      |> Task.map action
      |> Effects.task

userRolesUrl : AppConfig -> Product -> String
userRolesUrl appConfig prod = 
  appConfig.apiPath
  ++ "/products/"
  ++ (toString prod.id)
  ++ "/user-roles"

createUserRoleRequest : AppConfig -> Product -> UserRole -> Request
createUserRoleRequest appConfig product userRole = 
  Utils.Http.jsonPostRequest
    (userRolesUrl appConfig product) 
    (encodeUserRole userRole)

encodeUserRole : UserRole -> String
encodeUserRole userRole =
  Json.Encode.encode 0
    <| Json.Encode.object
        [ ("title",       Json.Encode.string userRole.title)
        , ("description", Json.Encode.string userRole.description)
        ]

parseUserRoles : Json.Decoder (List UserRole)
parseUserRoles = parseUserRole |> Json.list

parseUserRole : Json.Decoder UserRole
parseUserRole =
  Json.object2 UserRole
    ("title"       := Json.string)
    ("description" := Json.string)

