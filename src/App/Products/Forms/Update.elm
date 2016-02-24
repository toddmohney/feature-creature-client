module App.Products.Forms.Update
  ( update ) where

import App.AppConfig                 exposing (..)
import App.Products.Requests as P
import App.Products.Forms.Actions    exposing (..)
import App.Products.Forms.ViewModel  exposing (CreateProductForm, setName, setRepoUrl)
import App.Products.Forms.Validation exposing (hasErrors, validateForm)
import Debug                         exposing (crash)
import Effects                       exposing (Effects)
import Task as Task                  exposing (..)

update : Action -> CreateProductForm -> AppConfig -> (CreateProductForm, Effects Action)
update action form appConfig =
  case action of
    SetName name ->
      (setName form name, Effects.none)

    SetRepositoryUrl url ->
      (setRepoUrl form url, Effects.none)

    SubmitForm ->
      let newProductForm = validateForm form
      in
        case hasErrors newProductForm of
          True -> (newProductForm, Effects.none)
          False -> (newProductForm, P.createProduct appConfig newProductForm.newProduct ProductCreated)

    ProductCreated createProductResult ->
      case createProductResult of
        Ok product ->
          (,)
          { form | newProduct = product }
          (Effects.task (Task.succeed (NewProductCreated product)))
        Err _ ->
          crash "Failed to create product"

    NewProductCreated product -> (form, Effects.none)
