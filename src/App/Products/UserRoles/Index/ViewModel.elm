module App.Products.UserRoles.Index.ViewModel exposing
  ( UserRolesView
  , init
  )

import App.AppConfig                                 exposing (..)
import App.Products.Product                          exposing (Product)
import App.Products.UserRoles.Index.Actions          exposing (UserRoleAction(..))
import App.Products.UserRoles.Forms.ViewModel as URF exposing (UserRoleForm)
import App.Products.UserRoles.Requests               exposing (getUserRolesList)

type alias UserRolesView =
  { product      : Product
  , userRoleForm : Maybe UserRoleForm
  }

init : Product -> AppConfig -> (UserRolesView, Effects UserRoleAction)
init prod appConfig =
  ( { product = prod , userRoleForm = Nothing }
  , getUserRolesList appConfig prod UpdateUserRoles
  )
