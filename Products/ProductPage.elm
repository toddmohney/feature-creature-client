module Products.ProductPage where

import Debug exposing (crash)
import Effects exposing (Effects)
import Html exposing (Html)
import Html.Attributes exposing (..)
import Products.DomainTerms.DomainTermsView as DTV exposing (DomainTermsView)
import Products.FeaturesView as FV exposing (FeaturesView)
import Products.Product exposing (Product)
import UI.App.Components.ProductPageNavBar as PPVB exposing (NavBarItem)

type alias ProductPage =
  { product         : Product
  , selectedView    : ProductViewOption
  , featuresView    : FeaturesView
  , domainTermsView : DomainTermsView
  }

type ProductViewOption = FeaturesViewOption
                       | DomainTermsViewOption

type Action = FeaturesViewAction FV.Action
            | DomainTermsViewAction DTV.Action

init : Product -> (ProductPage, Effects Action)
init prod =
  let (featView, featuresViewFx)       = FV.init prod
      (domainTermsView, domainTermsFx) = DTV.init prod
      productPage = { product         = prod
                    , selectedView    = FeaturesViewOption
                    , featuresView    = featView
                    , domainTermsView = domainTermsView
                    }
  in ( productPage
     , Effects.batch [
         Effects.map FeaturesViewAction featuresViewFx
       , Effects.map DomainTermsViewAction domainTermsFx
       ]
     )

update : Action -> ProductPage -> (ProductPage, Effects Action)
update action productPage =
  case action of
    FeaturesViewAction fvAction ->
      let (featView, fvFx) = FV.update fvAction productPage.featuresView
      in ( { productPage | featuresView <- featView }
         , Effects.map FeaturesViewAction fvFx
         )

    DomainTermsViewAction dtvAction ->
      let (domainTermsView, dtvFx) = DTV.update dtvAction productPage.domainTermsView
      in ( { productPage | domainTermsView <- domainTermsView }
         , Effects.map DomainTermsViewAction dtvFx
         )

view : Signal.Address Action -> ProductPage -> Html
view address productPage =
  let navBar = renderNavBar productPage
      mainContent = case productPage.selectedView of
                      FeaturesViewOption -> renderFeaturesView address productPage
                      DomainTermsViewOption -> renderDomainTermsView address productPage
  in Html.div [] [ navBar, mainContent ]

renderNavBar : ProductPage -> Html
renderNavBar productPage =
  PPVB.renderNavBar [
      { attributes = [ classList [("active", productPage.selectedView == FeaturesViewOption)] ]
      , html = Html.a [] [ Html.text "Features" ]
      }
    , { attributes = [ classList [("active", productPage.selectedView == DomainTermsViewOption)] ]
      , html = Html.a [] [ Html.text "DomainTerms" ]
      }
    ]

renderFeaturesView : Signal.Address Action -> ProductPage -> Html
renderFeaturesView address productPage =
  Html.div
    []
    [ FV.view (Signal.forwardTo address FeaturesViewAction) productPage.featuresView ]

renderDomainTermsView : Signal.Address Action -> ProductPage -> Html
renderDomainTermsView address productPage =
  Html.div [] [ Html.text "Domain Terms! (Products.ProductPage)" ]

