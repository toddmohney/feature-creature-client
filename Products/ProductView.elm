module Products.ProductView where

import Effects                                     exposing (Effects)
import Html                                        exposing (Html)
import Products.DomainTerms.DomainTermsView as DTV exposing (DomainTermsView)
import Products.FeaturesView as FV                 exposing (FeaturesView)
import Products.Product                            exposing (Product)
import Products.Navigation as Nav
import Products.UserRoles.UserRolesView as URV     exposing (UserRolesView)
import UI.App.Components.ProductViewNavBar as PVNB exposing (ProductViewNavBar)

type alias ProductView =
  { product         : Product
  , navBar          : ProductViewNavBar
  , featuresView    : FeaturesView
  , domainTermsView : DomainTermsView
  , userRolesView   : UserRolesView
  }

type Action = FeaturesViewAction FV.Action
            | DomainTermsViewAction DTV.Action
            | UserRolesViewAction URV.Action
            | NavBarAction Nav.Action

init : List Product -> Product -> (ProductView, Effects Action)
init products selectedProduct =
  let (featView, featuresViewFx)       = FV.init selectedProduct
      (domainTermsView, domainTermsFx) = DTV.init selectedProduct
      (userRolesView, userRolesFx) = URV.init selectedProduct
      productView = { product         = selectedProduct
                    , navBar          = PVNB.init products selectedProduct
                    , featuresView    = featView
                    , domainTermsView = domainTermsView
                    , userRolesView   = userRolesView
                    }
  in ( productView
     , Effects.batch [
         Effects.map FeaturesViewAction featuresViewFx
       , Effects.map DomainTermsViewAction domainTermsFx
       , Effects.map UserRolesViewAction userRolesFx
       ]
     )

update : Action -> ProductView -> (ProductView, Effects Action)
update action productView =
  case action of
    NavBarAction navBarAction ->
      handleNavigation navBarAction productView

    FeaturesViewAction fvAction ->
      let (featView, fvFx) = FV.update fvAction productView.featuresView
      in ( { productView | featuresView = featView }
         , Effects.map FeaturesViewAction fvFx
         )

    DomainTermsViewAction dtvAction ->
      let (domainTermsView, dtvFx) = DTV.update dtvAction productView.domainTermsView
      in ( { productView | domainTermsView = domainTermsView }
         , Effects.map DomainTermsViewAction dtvFx
         )

    UserRolesViewAction urvAction ->
      let (userRolesView, urvFx) = URV.update urvAction productView.userRolesView
      in ( { productView | userRolesView = userRolesView }
         , Effects.map UserRolesViewAction urvFx
         )

handleNavigation : Nav.Action -> ProductView -> (ProductView, Effects Action)
handleNavigation navBarAction productView =
  let (updatedNavBar, navBarFx) = PVNB.update navBarAction productView.navBar
      newSelectedProduct        = updatedNavBar.selectedProduct
  in case productView.navBar.selectedProduct == newSelectedProduct of
       True -> ( { productView | navBar = updatedNavBar }
                , Effects.map NavBarAction navBarFx
                )
       False ->
         let (featView, featuresViewFx)       = FV.init newSelectedProduct
             (domainTermsView, domainTermsFx) = DTV.init newSelectedProduct
             (userRolesView, userRolesFx)     = URV.init newSelectedProduct
         in ( { productView |
                product         = newSelectedProduct
              , navBar          = updatedNavBar
              , featuresView    = featView
              , domainTermsView = domainTermsView
              , userRolesView   = userRolesView
              }
            , Effects.batch [
                Effects.map NavBarAction navBarFx
              , Effects.map FeaturesViewAction featuresViewFx
              , Effects.map DomainTermsViewAction domainTermsFx
              , Effects.map UserRolesViewAction userRolesFx
              ]
            )

view : Signal.Address Action -> ProductView -> Html
view address productView =
  let forwardedAddress = Signal.forwardTo address NavBarAction
      navBar = PVNB.view forwardedAddress productView.navBar
      mainContent = case productView.navBar.selectedView of
                      PVNB.FeaturesViewOption -> renderFeaturesView address productView
                      PVNB.DomainTermsViewOption -> renderDomainTermsView address productView
                      PVNB.UserRolesViewOption -> renderUserRolesView address productView
  in Html.div [] [ navBar, mainContent ]

renderFeaturesView : Signal.Address Action -> ProductView -> Html
renderFeaturesView address productView =
  let signal = (Signal.forwardTo address FeaturesViewAction)
  in Html.div [] [ FV.view signal productView.featuresView ]

renderDomainTermsView : Signal.Address Action -> ProductView -> Html
renderDomainTermsView address productView =
  let signal = (Signal.forwardTo address DomainTermsViewAction)
  in Html.div [] [ DTV.view signal productView.domainTermsView ]

renderUserRolesView : Signal.Address Action -> ProductView -> Html
renderUserRolesView address productView =
  let signal = (Signal.forwardTo address UserRolesViewAction)
  in Html.div [] [ URV.view signal productView.userRolesView ]
