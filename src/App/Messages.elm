module App.Messages exposing ( Msg(..) )

import App.AppConfig exposing (..)
import App.Products.Product    as P exposing (Product)
import App.Products.Navigation as Navigation
import App.Products.Messages   as P
import Http as Http exposing (Error)

type Msg = ProductsLoaded (Result Error (List Product))
         | ConfigLoaded AppConfig
         | ProductFormActions P.Msg
         | ProductViewActions P.Msg
         | NavigationActions Navigation.Action
         | TempProductsLoaded
