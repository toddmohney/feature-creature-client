module App.Products.UserRoles.UserRole where

import App.Search.Types as Search
import Json.Encode
import Json.Decode as Json exposing ((:=))

type alias UserRole =
  { title : String
  , description : String
  }

init : UserRole
init = { title = ""
       , description = ""
       }

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

toSearchQuery : UserRole -> Search.Query
toSearchQuery userRole =
  { datatype = "UserRole"
  , term = userRole.title
  }

