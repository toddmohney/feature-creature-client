module App.Products.UserRoles.UserRole
  ( UserRole
  , init
  , toSearchQuery
  ) where

import App.Search.Types as Search

type alias UserRole =
  { title : String
  , description : String
  }

init : UserRole
init = { title = ""
       , description = ""
       }

toSearchQuery : UserRole -> Search.Query
toSearchQuery userRole =
  { datatype = "UserRole"
  , term = userRole.title
  }

