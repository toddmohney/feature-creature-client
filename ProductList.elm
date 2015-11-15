module ProductList where

import Product as P

import Json.Decode as Json exposing ((:=))
import Http as Http        exposing (..)
import Html as Html        exposing (..)
import Task as Task        exposing (..)
import Html.Events         exposing (onClick)

import Effects exposing (Effects)

-- MODEL

type alias ProductList =
  { products: List P.Product
  , url: String
  , selectedProduct: Maybe P.Product
  }

init : (ProductList, Effects Action)
init =
  ( { products = []
    , url = productsEndpoint
    , selectedProduct = Nothing
    }
  , getProductList productsEndpoint
  )

productsEndpoint = "http://localhost:8081/products"

getProductList : String -> Effects Action
getProductList url =
   Http.get jsonToProducts url
    |> Task.toResult
    |> Task.map UpdateProducts
    |> Effects.task

jsonToProducts : Json.Decoder (List P.Product)
jsonToProducts =
  Json.object3 P.Product ("id" := Json.int) ("name" := Json.string) ("repoUrl" := Json.string)
    |> Json.list

-- UPDATE

type Action = RequestProducts
            | UpdateProducts (Result Error (List P.Product))
            | SelectProduct P.Product

update : Action -> ProductList -> (ProductList, Effects Action)
update action productList =
  case action of
    RequestProducts ->
      (productList, getProductList productList.url)
    UpdateProducts resultProducts ->
      case resultProducts of
        Ok newProducts ->
          ( { productList | products <- newProducts }
          , Effects.none
          )
        Err string -> (productList, Effects.none)
    SelectProduct prod ->
      ( { productList | selectedProduct <- Just prod }
      , Effects.none
      )

-- VIEW

view : Signal.Address Action -> ProductList -> Html
view address productList =
  let products = List.map (viewProduct address) productList.products
  in
    Html.div []
      [ Html.ul [] products
      , Html.button [onClick address RequestProducts] [Html.text "Reload products"]
      ]

viewProduct : Signal.Address Action -> P.Product -> Html
viewProduct address productList =
  Html.li
  [ onClick address (SelectProduct productList) ]
  [ P.view productList ]

