module ProductList where

import Product as P

import Json.Decode as Json exposing ((:=))
import Http as Http        exposing (..)
import Html as Html        exposing (..)
import Task as Task        exposing (..)
import Html.Events         exposing (onClick)

import Effects exposing (Effects)

-- import Effects exposing (Effects, Never)
-- import Html.Attributes exposing (style)
-- import Html.Events exposing (onClick)
-- import Json.Decode as Json
-- import Task

-- MODEL

type alias Model = 
  { products: List P.Model
  , url: String
  }

init : String -> (Model, Effects Action)
init url = 
  ( { products = [], url = url }
  , getProductList url
  )

getProductList : String -> Effects Action
getProductList url =
   Http.get jsonToProducts url
    |> Task.toResult
    |> Task.map UpdateProducts
    |> Effects.task

jsonToProducts : Json.Decoder (List P.Model)
jsonToProducts =
  Json.object3 P.Model ("id" := Json.int) ("name" := Json.string) ("repoUrl" := Json.string)
    |> Json.list

-- UPDATE

type Action = RequestProducts
            | UpdateProducts (Result Error (List P.Model))

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    RequestProducts ->
      (model, getProductList model.url)
    UpdateProducts resultProducts ->
      case resultProducts of
        Ok newProducts ->
          ( { model | products <- newProducts }
          , Effects.none
          )
        Err string -> (model, Effects.none)
-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  let products = List.map viewProduct model.products
  in
    Html.div []
      [ Html.ul [] products
      , Html.button [onClick address RequestProducts] [Html.text "Reload products"]
      ]

viewProduct : P.Model -> Html
viewProduct model = P.view model 
