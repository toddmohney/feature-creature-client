module App.Products.Forms.Update exposing ( update )

import App.AppConfig                 exposing (..)
import App.Products.Requests as P
import App.Products.Forms.ViewModel  exposing (CreateProductForm, setName, setRepoUrl)
import App.Products.Forms.Validation exposing (hasErrors, validateForm)
import App.Products.Messages         exposing (Msg(..))
import Debug                         exposing (crash)

update : Msg -> CreateProductForm -> AppConfig -> (CreateProductForm, Cmd Msg)
update msg form appConfig =
  case msg of
    SetName name ->
      (setName form name, Cmd.none)

    SetRepositoryUrl url ->
      (setRepoUrl form url, Cmd.none)

    SubmitForm ->
      let newProductForm = validateForm form
      in
        case hasErrors newProductForm of
          True -> (newProductForm, Cmd.none)
          False -> (newProductForm, P.createProduct appConfig newProductForm.newProduct)

    ProductCreated createProductResult ->
      case createProductResult of
        Ok product ->
          -- (,)
          -- { form | newProduct = product }
          -- (Cmd.map (\_ -> NewProductCreated product) Cmd.none)
          (,)
          { form | newProduct = product }
          Cmd.none
        Err _ ->
          crash "Failed to create product"

    -- this may now be unused
    NewProductCreated product -> (form, Cmd.none)

    _ -> (form, Cmd.none)
