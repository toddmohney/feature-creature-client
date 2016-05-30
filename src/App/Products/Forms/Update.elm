module App.Products.Forms.Update exposing ( update )

import App.AppConfig                 exposing (..)
import App.Products.Requests as P
import App.Products.Forms.ViewModel  exposing (CreateProductForm, setName, setRepoUrl)
import App.Products.Forms.Validation exposing (hasErrors, validateForm)
import App.Messages                  exposing (Msg(..))

update : Msg -> CreateProductForm -> AppConfig -> (CreateProductForm, Cmd Msg)
update msg form appConfig =
  case msg of
    CreateProductsSucceeded product -> ({ form | newProduct = product }, Cmd.none)
    CreateProductsFailed error      -> (form, Cmd.none)
    SetName name                    -> (setName form name, Cmd.none)
    SetRepositoryUrl url            -> (setRepoUrl form url, Cmd.none)
    SubmitForm                      -> submitForm form appConfig
    _                               -> (form, Cmd.none)

submitForm : CreateProductForm -> AppConfig -> (CreateProductForm, Cmd Msg)
submitForm form appConfig =
  let newProductForm = validateForm form
  in
    case hasErrors newProductForm of
      True -> (newProductForm, Cmd.none)
      False -> (newProductForm, P.createProduct appConfig newProductForm.newProduct)
