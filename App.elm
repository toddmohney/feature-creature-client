module App where

import Debug           exposing (crash)
import Effects         exposing (Effects)
import Html            exposing (Html)
import Html.Attributes exposing (class)
import Html.Events     exposing (onClick)
import Products.ProductList as ProdL exposing (..)
import Products.ProductPage as ProdP exposing (ProductPage)
import Products.FeaturesView as ProdV exposing (..)
import UI.App.Primitives.Buttons     exposing (primaryBtn)

type alias App =
  { productList : ProductList
  -- , productPage : Maybe ProductPage
  , productView : Maybe ProdV.FeaturesView
  }

init : (App, Effects Action)
init = let (prodList, fx) = ProdL.init
           app = { productList = prodList
                 -- , productPage = Nothing
                 , productView = Nothing
                 }
       in  ( app
           , Effects.map ProductListAction fx
           )

type Action = ProductListAction ProdL.Action
            | ProductViewAction ProdV.Action
            -- | ProductPageAction ProdP.Action
            | DeselectProduct

update : Action -> App -> (App, Effects Action)
update action app = case action of
  -- ProductListAction prodLAction ->
    -- let (prodList, prodListFx) = ProdL.update prodLAction app.productList
        -- (productPage, prodPageFx) = initProductPageView prodList
    -- in  ( { productList = prodList
          -- , productPage = productPage
          -- }
        -- , Effects.batch [
            -- Effects.map ProductListAction prodListFx
          -- , Effects.map ProductPageAction prodPageFx
          -- ]
        -- )
  ProductListAction prodLAction ->
    let (prodList, prodListFx) = ProdL.update prodLAction app.productList
        (featuresView, featuresFx) = initFeaturesView prodList
    in  ( { productList = prodList
          , productView = featuresView
          }
        , Effects.batch [
            Effects.map ProductListAction prodListFx
          , Effects.map ProductViewAction featuresFx
          ]
        )
  -- ProductPageAction prodPAction ->
    -- case app.productPage of
      -- Just productPage ->
        -- let (prodPage, fx) = ProdP.update prodPAction productPage
        -- in ( { app | productPage <- Just prodPage }
           -- , Effects.map ProductPageAction fx
           -- )
      -- Nothing -> (app, Effects.none)
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

-- initProductPageView : ProdL.ProductList -> (Maybe ProdP.ProductPage, Effects ProdP.Action)
-- initProductPageView prodList =
  -- case prodList.selectedProduct of
    -- Just prod ->
      -- let (productPage, fx) = ProdP.init prod
      -- in (Just productPage, fx)
    -- Nothing   -> (Nothing, Effects.none)

initFeaturesView : ProdL.ProductList -> (Maybe ProdV.FeaturesView, Effects ProdV.Action)
initFeaturesView prodList =
  case prodList.selectedProduct of
    Just prod ->
      let (productView, fx) = ProdV.init prod
      in  (Just productView, fx)
    Nothing   -> (Nothing, Effects.none)

-- view : Signal.Address Action -> App -> Html
-- view address app =
  -- case app.productPage of
    -- Just productPage -> renderProductPageView address productPage
    -- Nothing          -> productListView address app.productList

view : Signal.Address Action -> App -> Html
view address app =
  case app.productView of
    Just productView -> renderFeaturesView address productView
    Nothing          -> productListView address app.productList

-- renderProductPageView : Signal.Address Action -> ProdP.ProductPage -> Html
-- renderProductPageView address productPage =
  -- Html.div
  -- []
  -- [ primaryBtn [(onClick address DeselectProduct)] "Back"
  -- , Html.div
      -- [ class "clearfix" ]
      -- [ ProdP.view (Signal.forwardTo address ProductPageAction) productPage ]
  -- ]

renderFeaturesView : Signal.Address Action -> ProdV.FeaturesView -> Html
renderFeaturesView address productView =
  Html.div
  []
  [ primaryBtn [(onClick address DeselectProduct)] "Back"
  , Html.div
      [ class "clearfix" ]
      [ ProdV.view (Signal.forwardTo address ProductViewAction) productView ]
  ]

productListView : Signal.Address Action -> ProdL.ProductList -> Html
productListView address productList =  ProdL.view (Signal.forwardTo address ProductListAction) productList
