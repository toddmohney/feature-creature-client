module Products.CreateProductForm where

import Debug                 exposing (crash)
import Effects               exposing (Effects)
import Html                  exposing (Html)
import Html.Events           exposing (onClick)
import Http as Http          exposing (..)
import Products.Product as P exposing (Product)
import Task as Task          exposing (..)
import UI.App.Primitives.Forms     as UI exposing (..)
import Utils.Http

type alias CreateProductForm =
  { newProduct : Product }

type Action = SubmitForm
            | SetName String
            | SetRepositoryUrl String
            | HandleResponse (Result Error Product)
            | AddProduct Product

init : CreateProductForm
init = { newProduct = P.newProduct }

update : Action -> CreateProductForm -> (CreateProductForm, Effects Action)
update action form =
  case action of
    SetName name ->
      let product = form.newProduct
          updatedProduct = { product | name <- name }
      in ( { form | newProduct <- updatedProduct }
         , Effects.none
         )

    SetRepositoryUrl url ->
      let product = form.newProduct
          updatedProduct = { product | repoUrl <- url }
      in ( { form | newProduct <- updatedProduct }
         , Effects.none
         )

    SubmitForm ->
      ( form
      , createProduct form.newProduct
      )

    HandleResponse createProductResult ->
      case createProductResult of
        Ok product ->
          ( { form | newProduct <- P.newProduct }
          , Effects.none -- Effects.task AddProduct product
          )
        Err _ -> crash "Failed to create product"

    AddProduct product ->
      -- noop, we want someone higher up the chain to handle this effect
      ( form, Effects.none )

view : Signal.Address Action -> Html
view address =
  Html.div
    []
    [ UI.input address "name" (Html.text "Name") SetName
    , UI.textarea address "repoUrl" (Html.text "Git Repository Url") SetRepositoryUrl
    , UI.submitButton (onClick address SubmitForm)
    ]

createProduct : Product -> Effects Action
createProduct newProduct =
  let request = Utils.Http.jsonPostRequest createProductUrl (P.encodeProduct newProduct)
  in Http.send Http.defaultSettings request
     |> Http.fromJson P.parseProduct
     |> Task.toResult
     |> Task.map HandleResponse
     |> Effects.task

createProductUrl : String
createProductUrl = "http://localhost:8081/products"
