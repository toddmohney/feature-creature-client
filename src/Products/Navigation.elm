module Products.Navigation where

import Products.Product exposing (Product)

type Action = SelectFeaturesView
            | SelectDomainTermsView
            | SelectUserRolesView
            | SetSelectedProduct Product
            | ShowCreateNewProductForm
