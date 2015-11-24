module Products.ProductPage where

import Debug                                       exposing (crash)
import Effects                                     exposing (Effects)
import Html                                        exposing (Html)
import Html.Attributes                             exposing (..)
import Html.Events                                 exposing (onClick)
import Products.DomainTerms.DomainTermsView as DTV exposing (DomainTermsView)
import Products.FeaturesView as FV                 exposing (FeaturesView)
import Products.Product                            exposing (Product)
import UI.App.Components.ProductPageNavBar as PPNB exposing (ProductPageNavBar)

type alias ProductPage =
  { product         : Product
  , navBar          : ProductPageNavBar
  , featuresView    : FeaturesView
  , domainTermsView : DomainTermsView
  }

type Action = FeaturesViewAction FV.Action
            | DomainTermsViewAction DTV.Action
            | NavBarAction PPNB.Action

init : List Product -> Product -> (ProductPage, Effects Action)
init products selectedProduct =
  let (featView, featuresViewFx)       = FV.init selectedProduct
      (domainTermsView, domainTermsFx) = DTV.init selectedProduct
      productPage = { product         = selectedProduct
                    , navBar          = PPNB.init products selectedProduct
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
    NavBarAction navBarAction ->
      let (updatedNavBar, navBarFx) = PPNB.update navBarAction productPage.navBar
          newSelectedProduct        = updatedNavBar.selectedProduct
      in case productPage.navBar.selectedProduct == newSelectedProduct of
           True -> ( { productPage | navBar <- updatedNavBar }
                    , Effects.map NavBarAction navBarFx
                    )
           False ->
             let (featView, featuresViewFx)       = FV.init newSelectedProduct
                 (domainTermsView, domainTermsFx) = DTV.init newSelectedProduct
             in ( { productPage |
                    product         <- newSelectedProduct
                  , navBar          <- updatedNavBar
                  , featuresView    <- featView
                  , domainTermsView <- domainTermsView
                  }
                , Effects.batch [
                    Effects.map NavBarAction navBarFx
                  , Effects.map FeaturesViewAction featuresViewFx
                  , Effects.map DomainTermsViewAction domainTermsFx
                  ]
                )

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
  let forwardedAddress = Signal.forwardTo address NavBarAction
      navBar = PPNB.view forwardedAddress productPage.navBar
      mainContent = case productPage.navBar.selectedView of
                      PPNB.FeaturesViewOption -> renderFeaturesView address productPage
                      PPNB.DomainTermsViewOption -> renderDomainTermsView address productPage
  in Html.div [] [ navBar, mainContent ]

renderFeaturesView : Signal.Address Action -> ProductPage -> Html
renderFeaturesView address productPage =
  let signal = (Signal.forwardTo address FeaturesViewAction)
  in Html.div [] [ FV.view signal productPage.featuresView ]

renderDomainTermsView : Signal.Address Action -> ProductPage -> Html
renderDomainTermsView address productPage =
  let signal = (Signal.forwardTo address DomainTermsViewAction)
  in Html.div [] [ DTV.view signal productPage.domainTermsView ]

