module App.Products.UserRoles.UserRole
  ( UserRole
  , init
  , toSearchQuery
  ) where

import App.Search.Types as Search

type alias UserRole =
  { id          : Maybe Int
  , title       : String
  , description : String
  }

init : UserRole
init = init' Nothing

init' : Maybe Int -> UserRole
init' userRoleID =
  { id          = userRoleID
  , title       = ""
  , description = ""
  }

toSearchQuery : UserRole -> Search.Query
toSearchQuery userRole =
  { datatype = "UserRole"
  , term     = userRole.title
  }

