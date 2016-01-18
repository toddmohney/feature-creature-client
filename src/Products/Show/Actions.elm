module Products.Show.Actions where

import Products.DomainTerms.Index.Actions exposing (DomainTermAction)
import Products.Features.Index.Actions    as FV
import Products.Navigation                as Nav
import Products.UserRoles.UserRolesView   as URV

type Action = DomainTermsViewAction DomainTermAction
            | FeaturesViewAction FV.Action
            | NavBarAction Nav.Action
            | UserRolesViewAction URV.Action

