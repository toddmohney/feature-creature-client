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

type alias Model = 
  { productList : ProdL.Model 
  , featureList : Maybe FeatL.Model
  }

init : (Model, Effects Action)
init = let (prodList, fx) = ProdL.init productsEndpoint
       in  ( { productList = prodList, featureList = Nothing }
           , Effects.map ProductListAction fx
           )

-- UPDATE

type Action = ProductListAction ProdL.Action
            | FeatureListAction FeatL.Action
            | DeselectProduct

update : Action -> Model -> (Model, Effects Action)
update action model = case action of
  ProductListAction prodLAction ->
    let (prodList, prodFx) = ProdL.update prodLAction model.productList
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
    case model.featureList of
      Just origFeatL ->
        let (featL, fx) = FeatL.update featLAction origFeatL
        in ( { model | featureList <- Just featL }
           , Effects.map FeatureListAction fx
           )
      Nothing        -> (model, Effects.none)
  DeselectProduct ->
    ( { model | featureList <- Nothing }
    , Effects.none
    )

initFeatListFromProdList : ProdL.Model -> (Maybe FeatL.Model, Effects FeatL.Action)
initFeatListFromProdList prodList = case prodList.selectedProduct of
  Just prod -> 
    let (featList, fx) = FeatL.init prod.id
    in  (Just featList, fx)
  Nothing   -> (Nothing, Effects.none)

-- VIEW

view : Signal.Address Action -> Model -> Html
view address model = case model.featureList of
  Just featL -> featureListView address featL
  Nothing    -> productListView address model.productList

featureListView : Signal.Address Action -> FeatL.Model -> Html
featureListView address featureList = Html.div [] 
  [
    FeatL.view (Signal.forwardTo address FeatureListAction) featureList
  , Html.button [ onClick address DeselectProduct ] [ Html.text "Back" ]
  ]

productListView : Signal.Address Action -> ProdL.Model -> Html
productListView address productList =  ProdL.view (Signal.forwardTo address ProductListAction) productList



