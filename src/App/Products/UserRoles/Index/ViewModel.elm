module App.Products.UserRoles.Index.ViewModel
  ( UserRolesView
  , init
  ) where

import App.AppConfig                                 exposing (..)
import App.Products.UserRoles.Actions                exposing (UserRoleAction(..))
import App.Products.UserRoles.Requests               exposing (getUserRolesList)
import App.Products.Product                          exposing (Product)
import App.Products.UserRoles.Forms.ViewModel as URF exposing (UserRoleForm)
import Effects                                       exposing (Effects)

type alias UserRolesView =
  { product      : Product
  , userRoleForm : UserRoleForm
  }

init : Product -> AppConfig -> (UserRolesView, Effects UserRoleAction)
init prod appConfig =
  let effects = getUserRolesList appConfig prod UpdateUserRoles
  in (,)
     { product = prod
     , userRoleForm = URF.init prod
     }
     effects
