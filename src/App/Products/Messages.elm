module App.Products.Messages exposing (..)

import App.Products.DomainTerms.Messages   as DT
import App.Products.Features.Messages      as F
import App.Products.Navigation             as Navigation
import App.Products.Product exposing (Product)
import App.Products.UserRoles.Messages     as UR
import Http                 exposing (Error)

type Msg = DomainTermsViewAction DT.Msg
         | FeaturesViewAction F.Msg
         | NavBarAction Navigation.Action
         | UserRolesViewAction UR.Msg
         | SubmitForm
         | SetName String
         | SetRepositoryUrl String
         | ProductCreated (Result Error Product)
         | NewProductCreated Product
         | FetchProductsSucceeded (List Product)
         | FetchProductsFailed Error
         | CreateProductsSucceeded Product
         | CreateProductsFailed Error


