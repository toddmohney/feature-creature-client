module App.Products.Show.Update where

import Effects                                        exposing (Effects)
import App.Products.DomainTerms.Index.Actions as DT
import App.Products.DomainTerms.Index.ViewModel as DT
import App.Products.DomainTerms.Index.Update as DT
import App.Products.Features.Index.Actions as FeaturesActions
import App.Products.Features.Index.ViewModel as F
import App.Products.Features.Index.Update as F
import App.Products.Navigation as Navigation
import App.Products.Navigation.NavBar as NavBar
import App.Products.Product                           exposing (Product)
import App.Products.Show.Actions as Actions           exposing (Action)
import App.Products.Show.ViewModel                    exposing (ProductView)
import App.Products.UserRoles.UserRolesView as URV
import App.Search.Types as Search

update : Action -> ProductView -> (ProductView, Effects Action)
update action productView =
  case action of
    Actions.NavBarAction navBarAction ->
      handleNavigation navBarAction productView

    Actions.FeaturesViewAction fvAction ->
      let (featView, fvFx) = F.update fvAction productView.featuresView
      in case fvAction of
        -- This is a duplication of the action above
        -- how can we make this better?
        FeaturesActions.NavigationAction navAction ->
          handleNavigation navAction productView
        _ ->
          ( { productView | featuresView = featView }
            , Effects.map Actions.FeaturesViewAction fvFx
          )

    Actions.DomainTermsViewAction dtvAction ->
      let (domainTermsView, dtvFx) = DT.update dtvAction productView.domainTermsView
          newProductView = { productView | domainTermsView = domainTermsView }
      in case dtvAction of
        DT.SearchFeatures query ->
          ( newProductView
          , Effects.map Actions.FeaturesViewAction (searchFeatures newProductView.product query)
          )

        _ ->
          ( newProductView
          , Effects.map Actions.DomainTermsViewAction dtvFx
          )

    Actions.UserRolesViewAction urvAction ->
      let (userRolesView, urvFx) = URV.update urvAction productView.userRolesView
          newProductView = { productView | userRolesView = userRolesView }
      in case urvAction of
        URV.SearchFeatures query ->
          ( newProductView
          , Effects.map Actions.FeaturesViewAction (searchFeatures productView.product query)
          )

        _ ->
          ( newProductView
           , Effects.map Actions.UserRolesViewAction urvFx
          )

searchFeatures : Product -> Search.Query -> Effects FeaturesActions.Action
searchFeatures product query =
  F.getFeaturesList <| F.featuresUrl product (Just query)

handleNavigation : Navigation.Action -> ProductView -> (ProductView, Effects Action)
handleNavigation navBarAction productView =
  let (updatedNavBar, navBarFx) = NavBar.update navBarAction productView.navBar
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
