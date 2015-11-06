module App where

import Effects exposing (Effects)
import Html    exposing (Html)
import Debug   exposing (crash)

import ProductList as ProdL
import Product     as Prod

{- top-level values compile to JS as *CONSTANTS*, not functions -}
productsEndpoint = "http://private-d50ac-featurecreature.apiary-mock.com/products"

-- MODEL

type alias Model = 
  { productList: ProdL.Model
  , selectedProduct: Maybe Prod.Model
}

init : (Model, Effects Action)
init = let (prodList, fx) = ProdL.init productsEndpoint
       in  ( { productList = prodList
             , selectedProduct = Nothing
             }
           , Effects.map ProductListAction fx
           )


-- UPDATE

type Action = ProductListAction ProdL.Action

update : Action -> Model -> (Model, Effects Action)
update action model = case action of
  ProductListAction prodLAction ->
    let (prodList, fx) = ProdL.update prodLAction model.productList
    in  ( { model | productList <- prodList }
        , Effects.map ProductListAction fx
        )

-- VIEW

view : Signal.Address Action -> Model -> Html
view address model = case model.selectedProduct of
  Just prod -> crash "Implement selected product view!"
  Nothing   -> ProdL.view (Signal.forwardTo address ProductListAction) model.productList


