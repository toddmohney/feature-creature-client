module App where

import Effects     exposing (Effects)
import Html        exposing (Html)
import Html.Events exposing (onClick)
import Debug       exposing (crash)

import FeatureList as FeatL
import ProductList as ProdL

{- top-level values compile to JS as *CONSTANTS*, not functions -}
productsEndpoint = "http://localhost:8081/products"

-- MODEL

type alias App =
  { productList : ProdL.ProductList
  , featureList : Maybe FeatL.FeatureList
  }

init : (App, Effects Action)
init = let (prodList, fx) = ProdL.init productsEndpoint
       in  ( { productList = prodList, featureList = Nothing }
           , Effects.map ProductListAction fx
           )

-- UPDATE

type Action = ProductListAction ProdL.Action
            | FeatureListAction FeatL.Action
            | DeselectProduct

update : Action -> App -> (App, Effects Action)
update action app = case action of
  ProductListAction prodLAction ->
    let (prodList, prodFx) = ProdL.update prodLAction app.productList
        (maybeFeatList, featFx) = initFeatListFromProdList prodList
    in  ( { productList = prodList
          , featureList = maybeFeatList
          }
        , Effects.batch [
            Effects.map ProductListAction prodFx
          , Effects.map FeatureListAction featFx
          ]
        )
  FeatureListAction featLAction ->
    case app.featureList of
      Just origFeatL ->
        let (featL, fx) = FeatL.update featLAction origFeatL
        in ( { app | featureList <- Just featL }
           , Effects.map FeatureListAction fx
           )
      Nothing        -> (app, Effects.none)
  DeselectProduct ->
    ( { app | featureList <- Nothing }
    , Effects.none
    )

initFeatListFromProdList : ProdL.ProductList -> (Maybe FeatL.FeatureList, Effects FeatL.Action)
initFeatListFromProdList prodList = case prodList.selectedProduct of
  Just prod ->
    let (featList, fx) = FeatL.init prod.id
    in  (Just featList, fx)
  Nothing   -> (Nothing, Effects.none)

-- VIEW

view : Signal.Address Action -> App -> Html
view address app = case app.featureList of
  Just featL -> featureListView address featL
  Nothing    -> productListView address app.productList

featureListView : Signal.Address Action -> FeatL.FeatureList -> Html
featureListView address featureList = Html.div []
  [
    FeatL.view (Signal.forwardTo address FeatureListAction) featureList
  , Html.button [ onClick address DeselectProduct ] [ Html.text "Back" ]
  ]

productListView : Signal.Address Action -> ProdL.ProductList -> Html
productListView address productList =  ProdL.view (Signal.forwardTo address ProductListAction) productList



