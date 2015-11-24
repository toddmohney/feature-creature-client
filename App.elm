module App where

import Debug                      exposing (crash)
import Effects                    exposing (Effects)
import Html                       exposing (Html)
import Http as Http        exposing (..)
import Json.Decode as Json        exposing ((:=))
import Products.Product as P      exposing (Product)
import Products.ProductView as PV exposing (ProductView)
import Task as Task        exposing (..)

type alias App =
  { productView : Maybe ProductView }

type Action = ProductViewAction PV.Action
            | UpdateProducts (Result Error (List Product))

productsEndpoint = "http://localhost:8081/products"

init : (App, Effects Action)
init = ( { productView = Nothing }
       , getProducts productsEndpoint
       )

update : Action -> App -> (App, Effects Action)
update action app = case action of
  UpdateProducts resultProducts ->
    case resultProducts of
      Ok products -> initProductView products
      Err _ -> crash "Error: Failed to load Products"

  ProductViewAction prodPageAction ->
    case app.productView of
      Just productView ->
        let (prodPage, fx) = PV.update prodPageAction productView
        in ( { app | productView <- Just prodPage }
           , Effects.map ProductViewAction fx
           )
      Nothing -> (app, Effects.none)

initProductView : List Product -> (App, Effects Action)
initProductView products =
  let selectedProduct = List.head products
  in case selectedProduct of
    Just product ->
      let (prodPage, prodPageFx) = (PV.init products product)
      in ( { productView = Just prodPage }
      , Effects.map ProductViewAction prodPageFx
      )
    Nothing -> crash "Error: No Products found"

view : Signal.Address Action -> App -> Html
view address app =
  case app.productView of
    Just productView -> renderProductViewView address productView
    Nothing          -> Html.text "Loading stuff..."

renderProductViewView : Signal.Address Action -> ProductView -> Html
renderProductViewView address productView =
  let forwardedAddress = (Signal.forwardTo address ProductViewAction)
      productViewHtml = PV.view forwardedAddress productView
  in Html.div [] [ productViewHtml ]

getProducts : String -> Effects Action
getProducts url =
   Http.get parseProducts url
    |> Task.toResult
    |> Task.map UpdateProducts
    |> Effects.task

parseProducts : Json.Decoder (List Product)
parseProducts = parseProduct |> Json.list

parseProduct : Json.Decoder Product
parseProduct =
  Json.object3
    P.init'
    ("id" := Json.int)
    ("name" := Json.string)
    ("repoUrl" := Json.string)
