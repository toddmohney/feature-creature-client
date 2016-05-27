module App.Products.Messages exposing (..)

import App.Products.DomainTerms.Messages   as DT
import App.Products.Features.Messages      as F
import App.Products.Navigation             as Navigation
import App.Products.UserRoles.Messages     as UR

type Msg = DomainTermsViewAction DT.Msg
         | FeaturesViewAction F.Msg
         | NavBarAction Navigation.Action
         | UserRolesViewAction UR.Msg


