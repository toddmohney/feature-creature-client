module App.Products.Forms.Actions exposing ( Action(..) )

import Http                 exposing (Error)
import App.Products.Product exposing (Product)

type Action = SubmitForm
            | SetName String
            | SetRepositoryUrl String
            | ProductCreated (Result Error Product)
            | NewProductCreated Product


