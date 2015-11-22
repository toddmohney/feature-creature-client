module App where

import Debug           exposing (crash)
import Effects         exposing (Effects)
import Html            exposing (Html)
import Html.Attributes exposing (class)
import Html.Events     exposing (onClick)
import Products.ProductList as ProdL exposing (..)
import Products.ProductView as ProdV exposing (..)
import UI.App.Primitives.Buttons     exposing (primaryBtn)

type alias App =
  { productList : ProdL.ProductList
  , productView : Maybe ProdV.ProductView
  }

init : (App, Effects Action)
init = let (prodList, fx) = ProdL.init
           app = { productList = prodList
                 , productView = Nothing
                 }
       in  ( app
           , Effects.map ProductListAction fx
           )

type Action = ProductListAction ProdL.Action
            | ProductViewAction ProdV.Action
            | DeselectProduct

update : Action -> App -> (App, Effects Action)
update action app = case action of
  ProductListAction prodLAction ->
    let (prodList, prodListFx) = ProdL.update prodLAction app.productList
        (productView, prodViewFx) = initProductView prodList
    in  ( { productList = prodList
          , productView = productView
          }
        , Effects.batch [
            Effects.map ProductListAction prodListFx
          , Effects.map ProductViewAction prodViewFx
          ]
        )
  ProductViewAction productViewAction ->
    case app.productView of
      Just productView ->
        let (prodV, fx) = ProdV.update productViewAction productView
        in ( { app | productView <- Just prodV }
           , Effects.map ProductViewAction fx
           )
      Nothing -> (app, Effects.none)
  DeselectProduct ->
    ( { app | productView <- Nothing }
    , Effects.none
    )

initProductView : ProdL.ProductList -> (Maybe ProdV.ProductView, Effects ProdV.Action)
initProductView prodList =
  case prodList.selectedProduct of
    Just prod ->
      let (productView, fx) = ProdV.init prod
      in  (Just productView, fx)
    Nothing   -> (Nothing, Effects.none)

view : Signal.Address Action -> App -> Html
view address app =
  case app.productView of
    Just prodV -> renderProductView address prodV
    Nothing    -> productListView address app.productList

renderProductView : Signal.Address Action -> ProdV.ProductView -> Html
renderProductView address productView =
  Html.div
  []
  [ primaryBtn [(onClick address DeselectProduct)] "Back"
  , Html.div
      [ class "clearfix" ]
      [ ProdV.view (Signal.forwardTo address ProductViewAction) productView ]
  ]

productListView : Signal.Address Action -> ProdL.ProductList -> Html
productListView address productList =  ProdL.view (Signal.forwardTo address ProductListAction) productList
