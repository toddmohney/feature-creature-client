module App.Products.Forms.ViewModel exposing
  ( CreateProductForm
  , init
  , setName
  , setRepoUrl
  )

import App.Products.Product as P  exposing (Product)
import App.Products.Forms.Actions exposing (..)
import Html                       exposing (Html)
import UI.App.Primitives.Forms    exposing (InputField)

type alias CreateProductForm =
  { newProduct   : Product
  , nameField    : InputField Action
  , repoUrlField : InputField Action
  }

init : Product -> CreateProductForm
init product =
    { newProduct   = product
    , nameField    = defaultNameField product
    , repoUrlField = defaultRepoUrlField product
    }

setName : CreateProductForm -> String -> CreateProductForm
setName form newName =
  let product = form.newProduct
      newProduct = { product | name = newName }
  in
    init newProduct

setRepoUrl : CreateProductForm -> String -> CreateProductForm
setRepoUrl form newRepoUrl =
  let product = form.newProduct
      newProduct = { product | repoUrl = newRepoUrl }
  in
    init newProduct

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

