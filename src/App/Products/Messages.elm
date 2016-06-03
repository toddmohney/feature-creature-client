module App.Products.Messages exposing ( Msg (..) )

import App.Products.DomainTerms.Messages   as DT
import App.Products.Features.Messages      as F
import App.Products.Navigation             as Navigation
import App.Products.UserRoles.Messages     as UR

type Msg = DomainTermsViewMsg DT.Msg
         | FeaturesViewMsg F.Msg
         | NavBarMsg Navigation.Msg
         | UserRolesViewMsg UR.Msg


