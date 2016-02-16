module App.Products.Show.Actions where

import App.Products.DomainTerms.Index.Actions exposing (DomainTermAction)
import App.Products.Features.Index.Actions    as FV
import App.Products.Navigation        as Navigation
import App.Products.UserRoles.Actions   as UR

type Action = DomainTermsViewAction DomainTermAction
            | FeaturesViewAction FV.Action
            | NavBarAction Navigation.Action
            | UserRolesViewAction UR.UserRoleAction

