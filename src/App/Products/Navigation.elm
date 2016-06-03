module App.Products.Navigation exposing
  ( Action (..)
  , CurrentView (..)
  )

import App.Products.Product exposing (Product)

type Action = SelectFeaturesView
            | SelectDomainTermsView
            | SelectUserRolesView
            | SetSelectedProduct Product
            | ShowCreateNewProductForm
            | Login

type CurrentView = LoadingView
                 | ErrorView String
                 | CreateProductFormView
                 | ProductView
                 | DomainTermsView
                 | UserRolesView
