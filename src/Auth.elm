module Auth exposing
  ( OAuth
  , Msg (..)
  , postAuthorizationCode
  )

import App.AppConfig                       exposing (..)
import Http as Http exposing (..)
import Json.Encode
import Json.Decode as Json exposing ((:=))
import Task                                exposing (Task)
import Utils.Http

type Msg = AuthorizationCodeReceived String
         | CreateOAuthTokenFailed Error
         | CreateOAuthTokenSucceeded User

type alias OAuth = { authorizationCode : String }
type alias User =
  { id : Int
  , firstName : String
  , lastName : String
  }

postAuthorizationCode : AppConfig -> OAuth -> Cmd Msg
postAuthorizationCode appConfig oauth =
  Utils.Http.jsonPostRequest (authorizationCodeUrl appConfig oauth) (encodeOAuth oauth)
    |> Http.send Http.defaultSettings
    |> Http.fromJson parseUser
    |> Task.perform CreateOAuthTokenFailed CreateOAuthTokenSucceeded

authorizationCodeUrl : AppConfig -> OAuth -> String
authorizationCodeUrl appConfig oauth =
  Http.url (appConfig.apiPath ++ "/oauth/authorize") [("authToken", oauth.authorizationCode)]

encodeOAuth : OAuth -> String
encodeOAuth oauth =
  Json.Encode.encode 0
    <| Json.Encode.object
        [ ("authorizationCode", Json.Encode.string oauth.authorizationCode) ]

parseUser : Json.Decoder User
parseUser =
  Json.object3
    initUser
    ("id"        := Json.int)
    ("firstName" := Json.string)
    ("lastName"  := Json.string)

initUser : Int -> String -> String -> User
initUser = User
