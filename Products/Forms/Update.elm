module Products.Forms.Update
  ( update ) where

import Debug                   exposing (crash)
import Effects                 exposing (Effects)
import Http as Http            exposing (..)
import Products.Product as P   exposing (Product)
import Products.Forms.Actions  exposing (..)
import Products.Forms.Model    exposing (CreateProductForm)
import Products.Forms.Validation    exposing (hasErrors, validateForm)
import Task as Task            exposing (..)
import Utils.Http

update : Action -> CreateProductForm -> (CreateProductForm, Effects Action)
update action form =
  case action of
    SetName name ->
      let product = form.newProduct
          updatedProduct = { product | name = name }
      in ( { form | newProduct = updatedProduct }
         , Effects.none
         )

    SetRepositoryUrl url ->
      let product = form.newProduct
          updatedProduct = { product | repoUrl = url }
      in ( { form | newProduct = updatedProduct }
         , Effects.none
         )

    SubmitForm ->
      let newProductForm = validateForm form
      in
         case hasErrors newProductForm of
           True ->
             ( newProductForm
             , Effects.none
             )
           False ->
             ( newProductForm
             , createProduct newProductForm.newProduct
             )

    AddNewProduct createProductResult ->
      case createProductResult of
        Ok product ->
          ( { form | newProduct = product }
          , Effects.none
          )
        Err _ -> crash "Failed to create product"

createProduct : Product -> Effects Action
createProduct newProduct =
  let request = Utils.Http.jsonPostRequest createProductUrl (P.encodeProduct newProduct)
  in Http.send Http.defaultSettings request
     |> Http.fromJson P.parseProduct
     |> Task.toResult
     |> Task.map AddNewProduct
     |> Effects.task

createProductUrl : String
createProductUrl = "http://localhost:8081/products"
