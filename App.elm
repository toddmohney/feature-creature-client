module App where

import Debug                      exposing (crash)
import Effects                    exposing (Effects)
import Html                       exposing (Html)
import Http as Http        exposing (..)
import Json.Decode as Json        exposing ((:=))
import Products.Product as P      exposing (Product)
import Products.ProductPage as PP exposing (ProductPage)
import Task as Task        exposing (..)

type alias App =
  { productPage : Maybe ProductPage }

type Action = ProductPageAction PP.Action
            | UpdateProducts (Result Error (List Product))

productsEndpoint = "http://localhost:8081/products"

init : (App, Effects Action)
init = ( { productPage = Nothing }
       , getProducts productsEndpoint
       )

update : Action -> App -> (App, Effects Action)
update action app = case action of
  UpdateProducts resultProducts ->
    case resultProducts of
      Ok products -> initProductPage products
      Err _ -> crash "Error: Failed to load Products"

  ProductPageAction prodPageAction ->
    case app.productPage of
      Just productPage ->
        let (prodPage, fx) = PP.update prodPageAction productPage
        in ( { app | productPage <- Just prodPage }
           , Effects.map ProductPageAction fx
           )
      Nothing -> (app, Effects.none)

initProductPage : List Product -> (App, Effects Action)
initProductPage products =
  let selectedProduct = List.head products
  in case selectedProduct of
    Just product ->
      let (prodPage, prodPageFx) = (PP.init products product)
      in ( { productPage = Just prodPage }
      , Effects.map ProductPageAction prodPageFx
      )
    Nothing -> crash "Error: No Products found"

view : Signal.Address Action -> App -> Html
view address app =
  case app.productPage of
    Just productPage -> renderProductPageView address productPage
    Nothing          -> Html.text "Loading stuff..."

renderProductPageView : Signal.Address Action -> ProductPage -> Html
renderProductPageView address productPage =
  let forwardedAddress = (Signal.forwardTo address ProductPageAction)
      productPageHtml = PP.view forwardedAddress productPage
  in Html.div [] [ productPageHtml ]

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
