module Products.Forms.Actions
  ( Action(..) ) where

import Http             exposing (Error)
import Products.Product exposing (Product)

type Action = SubmitForm
            | SetName String
            | SetRepositoryUrl String
            | AddNewProduct (Result Error Product)


