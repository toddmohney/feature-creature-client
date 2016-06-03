module App.Messages exposing ( Msg (..) )

import Auth
import App.Products.Product    as P exposing (Product)
import App.Products.Navigation as Navigation
import App.Products.Messages   as P
import Http as Http exposing (Error)

type Msg = AuthenticationMsgs Auth.Msg
         | ProductViewMsgs P.Msg
         | NavigationMsgs Navigation.Msg
         | FetchProductsSucceeded (List Product)
         | FetchProductsFailed Error
         | CreateProductsSucceeded Product
         | CreateProductsFailed Error
         | SetName String
         | SetRepositoryUrl String
         | SubmitForm
