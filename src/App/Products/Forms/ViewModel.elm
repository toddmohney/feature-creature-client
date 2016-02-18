module App.Products.Forms.ViewModel
  ( CreateProductForm
  , init
  ) where

import App.Products.Product as P  exposing (Product)
import App.Products.Forms.Actions exposing (..)
import Html                       exposing (Html)
import UI.App.Primitives.Forms    exposing (InputField)

type alias CreateProductForm =
  { newProduct   : Product
  , nameField    : InputField Action
  , repoUrlField : InputField Action
  }

init : CreateProductForm
init =
  let product = P.newProduct
  in
    { newProduct   = product
    , nameField    = defaultNameField product
    , repoUrlField = defaultRepoUrlField product
    }

defaultNameField : Product -> InputField Action
defaultNameField product =
  { defaultValue = product.name
  , inputName = "name"
  , inputParser = SetName
  , labelContent = (Html.text "Name")
  , validationErrors = []
  }

defaultRepoUrlField : Product -> InputField Action
defaultRepoUrlField product =
  { defaultValue = product.repoUrl
  , inputName = "repoUrl"
  , inputParser = SetRepositoryUrl
  , labelContent = (Html.text "Git Repository Url")
  , validationErrors = []
  }

