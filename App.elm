module App where

import Debug                      exposing (crash)
import Effects                    exposing (Effects)
import Html                       exposing (Html)
import Products.ProductPage as PP exposing (ProductPage)
import Task as Task        exposing (..)

type alias App =
  { productPage : ProductPage }

type Action = ProductPageAction PP.Action

init : (App, Effects Action)
init =
  let (newProductPage, productPageFx) = PP.init
  in ( { productPage = newProductPage }
     , Effects.map ProductPageAction productPageFx
     )

update : Action -> App -> (App, Effects Action)
update action app =
  case action of
    ProductPageAction ppAction ->
      let (updatedProductPage, fx) = PP.update ppAction app.productPage
      in ( { app | productPage <- updatedProductPage }
         , Effects.map ProductPageAction fx
         )

view : Signal.Address Action -> App -> Html
view address app =
  let forwardedAddress = Signal.forwardTo address ProductPageAction
  in Html.div [] [ PP.view forwardedAddress app.productPage ]
