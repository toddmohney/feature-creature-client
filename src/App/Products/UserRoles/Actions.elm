module App.Products.UserRoles.Actions 
  ( Action (..)
  ) where

import App.Products.UserRoles.Forms.Actions as URF
import App.Search.Types as Search
import App.Products.UserRoles.UserRole exposing (UserRole)
import Http                            exposing (Error)

type Action = UpdateUserRoles (Result Error (List UserRole))
            | UserRoleFormAction URF.Action
            | SearchFeatures Search.Query
