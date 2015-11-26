module Products.Navigation where

import Products.Product exposing (Product)

type Action = SelectFeaturesView
            | SelectDomainTermsView
            | SetSelectedProduct Product
            | ShowCreateNewProductForm
