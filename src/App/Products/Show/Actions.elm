module App.Products.Show.Actions where

import App.Products.DomainTerms.Index.Actions exposing (DomainTermAction)
import App.Products.Features.Index.Actions    as FV
import App.Products.Navigation        as Navigation
import App.Products.UserRoles.UserRolesView   as URV

type Action = DomainTermsViewAction DomainTermAction
            | FeaturesViewAction FV.Action
            | NavBarAction Navigation.Action
            | UserRolesViewAction URV.Action

