module App.Messages exposing ( Msg (..) )

import Auth
import App.Products.Product    as P exposing (Product)
import App.Products.Navigation as Navigation
import App.Products.Messages   as P
import Http as Http exposing (Error)

type Msg = AuthenticationActions Auth.Msg
         | ProductViewActions P.Msg
         | NavigationActions Navigation.Action
         | FetchProductsSucceeded (List Product)
         | FetchProductsFailed Error
         | CreateProductsSucceeded Product
         | CreateProductsFailed Error
         | SetName String
         | SetRepositoryUrl String
         | SubmitForm
