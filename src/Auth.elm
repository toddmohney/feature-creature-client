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
  Http.get parseUser (authorizationCodeUrl appConfig oauth)
    |> Task.perform CreateOAuthTokenFailed CreateOAuthTokenSucceeded

authorizationCodeUrl : AppConfig -> OAuth -> String
authorizationCodeUrl appConfig oauth =
  Http.url (appConfig.apiPath ++ "/users/authorize") [("authCode", oauth.authorizationCode)]

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
