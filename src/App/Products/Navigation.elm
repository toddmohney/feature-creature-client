module App.Products.Navigation exposing
  ( Msg (..)
  , CurrentView (..)
  )

import App.Products.Product exposing (Product)

type Msg = SelectFeaturesView
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
