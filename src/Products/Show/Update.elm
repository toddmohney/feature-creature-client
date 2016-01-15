module Products.Show.Update where

import Debug                                       exposing (crash, log)
import Effects                                     exposing (Effects)
import Products.DomainTerms.Index.Actions as DT
import Products.DomainTerms.Index.ViewModel as DT
import Products.DomainTerms.Index.Update as DT
import Products.Features.Index.ViewModel as F
import Products.Features.Index.Update as F
import Products.Navigation as Nav
import Products.Show.Actions as Actions exposing (Action)
import Products.Show.ViewModel exposing (ProductView)
import Products.UserRoles.UserRolesView as URV
import UI.App.Components.ProductViewNavBar as PVNB

update : Action -> ProductView -> (ProductView, Effects Action)
update action productView =
  case action of
    Actions.NavBarAction navBarAction ->
      handleNavigation navBarAction productView

    Actions.FeaturesViewAction fvAction ->
      let (featView, fvFx) = F.update fvAction productView.featuresView
      in ( { productView | featuresView = featView }
         , Effects.map Actions.FeaturesViewAction fvFx
         )

    Actions.DomainTermsViewAction dtvAction ->
      case dtvAction of
        DT.SearchFeatures query ->
          let (domainTermsView, dtvFx) = DT.update dtvAction productView.domainTermsView
              whatever = log "ProductView.SearchFeatures: " query
          in ( { productView | domainTermsView = domainTermsView }
             , Effects.map Actions.DomainTermsViewAction dtvFx
             )

        _ ->
          let (domainTermsView, dtvFx) = DT.update dtvAction productView.domainTermsView
              query = log "ProductView (pass-through): " dtvAction
          in ( { productView | domainTermsView = domainTermsView }
             , Effects.map Actions.DomainTermsViewAction dtvFx
             )

    Actions.UserRolesViewAction urvAction ->
      let (userRolesView, urvFx) = URV.update urvAction productView.userRolesView
      in ( { productView | userRolesView = userRolesView }
         , Effects.map Actions.UserRolesViewAction urvFx
         )

handleNavigation : Nav.Action -> ProductView -> (ProductView, Effects Action)
handleNavigation navBarAction productView =
  let (updatedNavBar, navBarFx) = PVNB.update navBarAction productView.navBar
      newSelectedProduct        = updatedNavBar.selectedProduct
  in case productView.navBar.selectedProduct == newSelectedProduct of
       True -> ( { productView | navBar = updatedNavBar }
                , Effects.map Actions.NavBarAction navBarFx
                )
       False ->
         let (featView, featuresViewFx)       = F.init newSelectedProduct
             (domainTermsView, domainTermsFx) = DT.init newSelectedProduct
             (userRolesView, userRolesFx)     = URV.init newSelectedProduct
         in ( { productView |
                product         = newSelectedProduct
              , navBar          = updatedNavBar
              , featuresView    = featView
              , domainTermsView = domainTermsView
              , userRolesView   = userRolesView
              }
            , Effects.batch [
                Effects.map Actions.NavBarAction navBarFx
              , Effects.map Actions.FeaturesViewAction featuresViewFx
              , Effects.map Actions.DomainTermsViewAction domainTermsFx
              , Effects.map Actions.UserRolesViewAction userRolesFx
              ]
            )
