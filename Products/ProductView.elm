module Products.ProductView where

import Debug                                       exposing (crash)
import Effects                                     exposing (Effects)
import Html                                        exposing (Html)
import Html.Attributes                             exposing (..)
import Html.Events                                 exposing (onClick)
import Products.DomainTerms.DomainTermsView as DTV exposing (DomainTermsView)
import Products.FeaturesView as FV                 exposing (FeaturesView)
import Products.Product                            exposing (Product)
import UI.App.Components.ProductViewNavBar as PVNB exposing (ProductViewNavBar)

type alias ProductView =
  { product         : Product
  , navBar          : ProductViewNavBar
  , featuresView    : FeaturesView
  , domainTermsView : DomainTermsView
  }

type Action = FeaturesViewAction FV.Action
            | DomainTermsViewAction DTV.Action
            | NavBarAction PVNB.Action

init : List Product -> Product -> (ProductView, Effects Action)
init products selectedProduct =
  let (featView, featuresViewFx)       = FV.init selectedProduct
      (domainTermsView, domainTermsFx) = DTV.init selectedProduct
      productView = { product         = selectedProduct
                    , navBar          = PVNB.init products selectedProduct
                    , featuresView    = featView
                    , domainTermsView = domainTermsView
                    }
  in ( productView
     , Effects.batch [
         Effects.map FeaturesViewAction featuresViewFx
       , Effects.map DomainTermsViewAction domainTermsFx
       ]
     )

update : Action -> ProductView -> (ProductView, Effects Action)
update action productView =
  case action of
    NavBarAction navBarAction ->
      let (updatedNavBar, navBarFx) = PVNB.update navBarAction productView.navBar
          newSelectedProduct        = updatedNavBar.selectedProduct
      in case productView.navBar.selectedProduct == newSelectedProduct of
           True -> ( { productView | navBar <- updatedNavBar }
                    , Effects.map NavBarAction navBarFx
                    )
           False ->
             let (featView, featuresViewFx)       = FV.init newSelectedProduct
                 (domainTermsView, domainTermsFx) = DTV.init newSelectedProduct
             in ( { productView |
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
      let (featView, fvFx) = FV.update fvAction productView.featuresView
      in ( { productView | featuresView <- featView }
         , Effects.map FeaturesViewAction fvFx
         )

    DomainTermsViewAction dtvAction ->
      let (domainTermsView, dtvFx) = DTV.update dtvAction productView.domainTermsView
      in ( { productView | domainTermsView <- domainTermsView }
         , Effects.map DomainTermsViewAction dtvFx
         )

view : Signal.Address Action -> ProductView -> Html
view address productView =
  let forwardedAddress = Signal.forwardTo address NavBarAction
      navBar = PVNB.view forwardedAddress productView.navBar
      mainContent = case productView.navBar.selectedView of
                      PVNB.FeaturesViewOption -> renderFeaturesView address productView
                      PVNB.DomainTermsViewOption -> renderDomainTermsView address productView
  in Html.div [] [ navBar, mainContent ]

renderFeaturesView : Signal.Address Action -> ProductView -> Html
renderFeaturesView address productView =
  let signal = (Signal.forwardTo address FeaturesViewAction)
  in Html.div [] [ FV.view signal productView.featuresView ]

renderDomainTermsView : Signal.Address Action -> ProductView -> Html
renderDomainTermsView address productView =
  let signal = (Signal.forwardTo address DomainTermsViewAction)
  in Html.div [] [ DTV.view signal productView.domainTermsView ]

