module Products.Forms.ViewModel
  ( CreateProductForm
  , init
  ) where

import Html                  exposing (Html)
import Products.Product        exposing (Product, newProduct)
import Products.Forms.Actions  exposing (..)
import UI.App.Primitives.Forms exposing (InputField)

type alias CreateProductForm =
  { newProduct   : Product
  , nameField    : InputField Action
  , repoUrlField : InputField Action
  }

init : CreateProductForm
init = { newProduct   = newProduct
       , nameField    = defaultNameField
       , repoUrlField = defaultRepoUrlField
       }

defaultNameField : InputField Action
defaultNameField =
  { inputName = "name"
  , labelContent = (Html.text "Name")
  , inputParser = SetName
  , validationErrors = []
  }

defaultRepoUrlField : InputField Action
defaultRepoUrlField =
  { inputName = "repoUrl"
  , labelContent = (Html.text "Git Repository Url")
  , inputParser = SetRepositoryUrl
  , validationErrors = []
  }

