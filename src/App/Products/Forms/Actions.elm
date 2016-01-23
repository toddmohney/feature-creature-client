module App.Products.Forms.Actions
  ( Action(..) ) where

import Http                 exposing (Error)
import App.Products.Product exposing (Product)

type Action = SubmitForm
            | SetName String
            | SetRepositoryUrl String
            | ProductCreated (Result Error Product)
            | NewProductCreated Product


