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
  , featuresView    : Maybe FeaturesView
  , domainTermsView : Maybe DomainTermsView
  }

type ProductViewOption = FeaturesViewOption
                       | DomainTermsViewOption

type Action = FeaturesViewAction FV.Action

init : Product -> (ProductPage, Effects FV.Action)
init prod =
  let (featView, fx) = FV.init prod
      productPage = { product = prod
                    , selectedView = FeaturesViewOption
                    , featuresView = Just featView
                    , domainTermsView = Nothing
                    }
  in (productPage, fx)

update : Action -> ProductPage -> (ProductPage, Effects Action)
update = crash "ProductPage Crash (update)"

view : Signal.Address Action -> ProductPage -> Html
view address productPage =
  case productPage.selectedView of
    FeaturesViewOption -> renderFeaturesView address productPage
    DomainTermsViewOption -> renderDomainTermsView address productPage

renderFeaturesView : Signal.Address Action -> ProductPage -> Html
renderFeaturesView address productPage =
  case productPage.featuresView of
    Just featuresView ->
      Html.div
        []
        [ Html.text "hi!"
        , FV.view (Signal.forwardTo address FeaturesViewAction) featuresView
        ]
    Nothing ->
      Html.div
        []
        [ Html.text "uh oh, no FeaturesView found!" ]

renderDomainTermsView : Signal.Address Action -> ProductPage -> Html
renderDomainTermsView address productPage =
  Html.div
    []
    [ Html.text "Domain Terms! (Products.ProductPage)" ]

