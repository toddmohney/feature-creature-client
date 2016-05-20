module App.Products.Show.Actions exposing (..)

import App.Products.DomainTerms.Index.Actions exposing (DomainTermAction)
import App.Products.Features.Index.Actions    as FV
import App.Products.Navigation        as Navigation
import App.Products.UserRoles.Index.Actions   exposing (UserRoleAction)

type Action = DomainTermsViewAction DomainTermAction
            | FeaturesViewAction FV.Action
            | NavBarAction Navigation.Action
            | UserRolesViewAction UserRoleAction

