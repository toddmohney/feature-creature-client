module App.Products.Forms.Validation
  ( validateForm
  , hasErrors
  ) where

import App.Products.Forms.ViewModel exposing (CreateProductForm)
import UI.App.Primitives.Forms      exposing (requiredStringFieldValidation)

validateForm : CreateProductForm -> CreateProductForm
validateForm createProductForm =
  let product         = createProductForm.newProduct
      nameField       = createProductForm.nameField
      repoUrlField    = createProductForm.repoUrlField
      newNameField    = { nameField | validationErrors    = validateName product.name }
      newRepoUrlField = { repoUrlField | validationErrors = validateRepoUrl product.repoUrl }
  in
     { createProductForm | nameField = newNameField
                         , repoUrlField = newRepoUrlField
     }

validateName : String -> (List String)
validateName = requiredStringFieldValidation

validateRepoUrl : String -> (List String)
validateRepoUrl = requiredStringFieldValidation

hasErrors : CreateProductForm -> Bool
hasErrors = not << isSubmittable

isSubmittable : CreateProductForm -> Bool
isSubmittable createProductForm =
  let nameField    = createProductForm.nameField
      repoUrlField = createProductForm.repoUrlField
  in
     (List.isEmpty nameField.validationErrors)
     && (List.isEmpty repoUrlField.validationErrors)

