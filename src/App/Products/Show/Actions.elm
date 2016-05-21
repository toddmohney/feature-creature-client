module App.Products.Show.Actions exposing (..)

import App.Products.DomainTerms.Messages   as DT
import App.Products.Features.Index.Actions as FV
import App.Products.Navigation             as Navigation
import App.Products.UserRoles.Messages     as UR

type Action = DomainTermsViewAction DT.Msg
            | FeaturesViewAction FV.Action
            | NavBarAction Navigation.Action
            | UserRolesViewAction UR.Msg

