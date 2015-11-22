module Products.ProductPage where

import Debug exposing (crash)
import Effects exposing (Effects)
import Html exposing (Html)
import Products.DomainTerms.DomainTermsView exposing (DomainTermsView)
import Products.FeaturesView as FV exposing (FeaturesView)
import Products.Product exposing (Product)

type alias ProductPage =
  { product         : Product
  , selectedView    : ProductViewOption
  , featuresView    : FeaturesView
  , domainTermsView : Maybe DomainTermsView
  }

type ProductViewOption = FeaturesViewOption
                       | DomainTermsViewOption

type Action = FeaturesViewAction FV.Action

init : Product -> (ProductPage, Effects Action)
init prod =
  let (featView, fx) = FV.init prod
      productPage = { product = prod
                    , selectedView = FeaturesViewOption
                    , featuresView = featView
                    , domainTermsView = Nothing
                    }
  in (productPage, (Effects.map FeaturesViewAction fx))

update : Action -> ProductPage -> (ProductPage, Effects Action)
update action productPage =
  case action of
    FeaturesViewAction fvAction ->
      let (featView, fvFx) = FV.update fvAction productPage.featuresView
      in ( { productPage | featuresView <- featView }
         , Effects.map FeaturesViewAction fvFx
         )


view : Signal.Address Action -> ProductPage -> Html
view address productPage =
  case productPage.selectedView of
    FeaturesViewOption -> renderFeaturesView address productPage
    DomainTermsViewOption -> renderDomainTermsView address productPage

renderFeaturesView : Signal.Address Action -> ProductPage -> Html
renderFeaturesView address productPage =
  Html.div
    []
    [ FV.view (Signal.forwardTo address FeaturesViewAction) productPage.featuresView ]

renderDomainTermsView : Signal.Address Action -> ProductPage -> Html
renderDomainTermsView address productPage =
  Html.div
    []
    [ Html.text "Domain Terms! (Products.ProductPage)" ]

