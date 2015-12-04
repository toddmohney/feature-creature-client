module Products.UserRoles.Forms.Actions where

import Http exposing (Error)
import Products.UserRoles.UserRole as UR exposing (UserRole)

type Action = AddUserRole (Result Error UserRole)
            | ShowUserRoleForm
            | HideUserRoleForm
            | SubmitUserRoleForm
            | SetUserRoleTitle String
            | SetUserRoleDescription String

