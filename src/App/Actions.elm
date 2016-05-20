module App.Actions exposing ( Action(..) )

import App.AppConfig                                      exposing (..)
import App.Products.Product         as P                  exposing (Product)
import App.Products.Forms.Actions   as ProductFormActions
import App.Products.Navigation      as Navigation
import App.Products.Show.Actions    as ProductViewActions
import Http as Http                                       exposing (Error)

type Action = ProductsLoaded (Result Error (List Product))
            | ConfigLoaded AppConfig
            | ProductFormActions ProductFormActions.Action
            | ProductViewActions ProductViewActions.Action
            | NavigationActions Navigation.Action
