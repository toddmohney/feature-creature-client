module App.Products.UserRoles.Index.Actions where

import App.Products.UserRoles.Forms.Actions as URF
import App.Search.Types as Search
import App.Products.UserRoles.UserRole exposing (UserRole)
import Http                            exposing (Error)

type UserRoleAction = UpdateUserRoles (Result Error (List UserRole))
                    | SearchFeatures Search.Query
                    | RemoveUserRole UserRole
                    | UserRoleRemoved (Result Error UserRole)
                    | UserRoleFormAction URF.Action
                    | ShowCreateUserRoleForm
                    | ShowEditUserRoleForm UserRole
                    | HideUserRoleForm
