module App.Products.UserRoles.Forms.Actions
  ( Action(..) ) where

import Http exposing (Error)
import App.Products.UserRoles.UserRole as UR exposing (UserRole)

type Action = AddUserRole (Result Error UserRole)
            | ShowUserRoleForm
            | HideUserRoleForm
            | SubmitUserRoleForm
            | SetUserRoleTitle String
            | SetUserRoleDescription String

