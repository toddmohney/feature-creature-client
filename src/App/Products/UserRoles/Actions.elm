module App.Products.UserRoles.Actions
  ( UserRoleAction (..)
  ) where

import App.Products.UserRoles.Forms.Actions as URF
import App.Search.Types as Search
import App.Products.UserRoles.UserRole exposing (UserRole)
import Http                            exposing (Error)

type UserRoleAction = UpdateUserRoles (Result Error (List UserRole))
                    | UserRoleFormAction URF.Action
                    | SearchFeatures Search.Query
                    | EditUserRole UserRole
                    | RemoveUserRole UserRole
                    | UserRoleRemoved (Result Error UserRole)
