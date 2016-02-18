module App.Products.UserRoles.Forms.Actions
  ( Action(..)
  ) where

import App.Products.UserRoles.UserRole as UR exposing (UserRole)
import Http                                  exposing (Error)

type Action = UserRoleAdded UserRole
            | UserRoleUpdated UserRole
            | UserRoleCreated (Result Error UserRole)
            | UserRoleModified (Result Error UserRole)
            | SubmitUserRoleForm
            | SetUserRoleTitle String
            | SetUserRoleDescription String
