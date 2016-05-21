module App.Products.Show.Update exposing (..)

import App.AppConfig                                  exposing (..)
import App.Products.DomainTerms.Messages as DT
import App.Products.DomainTerms.Index.Update as DT
import App.Products.Features.Index.Actions as FeaturesActions
import App.Products.Features.Index.Update as F
import App.Products.Features.Requests as F
import App.Products.Navigation as Navigation
import App.Products.Navigation.NavBar as NavBar
import App.Products.Product                           exposing (Product)
import App.Products.Show.Actions as Actions           exposing (Action)
import App.Products.Show.ViewModel as PV              exposing (ProductView)
import App.Products.UserRoles.Messages as UR
import App.Products.UserRoles.Index.Update as URV
import App.Search.Types as Search

update : Action -> ProductView -> AppConfig -> (ProductView, Effects Action)
update action productView appConfig =
  case action of
    Actions.NavBarAction navBarAction -> handleNavigation appConfig navBarAction productView

    Actions.FeaturesViewAction fvAction ->
      let (featView, fvFx) = F.update appConfig fvAction productView.featuresView
      in case fvAction of
        -- This is a duplication of the action above
        -- how can we make this better?
        FeaturesActions.NavigationAction navAction -> handleNavigation appConfig navAction productView
        _ ->
          ( { productView | featuresView = featView }
            , Effects.map Actions.FeaturesViewAction fvFx
          )

    Actions.DomainTermsViewAction dtvAction ->
      let (domainTermsView, dtvFx) = DT.update dtvAction productView.domainTermsView appConfig
          newProductView = { productView | domainTermsView = domainTermsView }
      in case dtvAction of
        DT.SearchFeatures query ->
          ( newProductView
          , Effects.map Actions.FeaturesViewAction (searchFeatures appConfig newProductView.product query)
          )

        _ ->
          ( newProductView
          , Effects.map Actions.DomainTermsViewAction dtvFx
          )

    Actions.UserRolesViewAction urvAction ->
      let (userRolesView, urvFx) = URV.update urvAction productView.userRolesView appConfig
          newProductView = { productView | userRolesView = userRolesView }
      in case urvAction of
        UR.SearchFeatures query ->
          ( newProductView
          , Effects.map Actions.FeaturesViewAction (searchFeatures appConfig productView.product query)
          )

        _ ->
          ( newProductView
           , Effects.map Actions.UserRolesViewAction urvFx
          )

searchFeatures : AppConfig -> Product -> Search.Query -> Effects FeaturesActions.Action
searchFeatures appConfig product query =
  let searchQuery = Just query
      action = FeaturesActions.UpdateFeatures searchQuery
  in
    F.getFeaturesList appConfig product searchQuery action

handleNavigation : AppConfig -> Navigation.Action -> ProductView -> (ProductView, Effects Action)
handleNavigation appConfig navBarAction productView =
  let (updatedNavBar, navBarFx) = NavBar.update navBarAction productView.navBar
      newSelectedProduct        = updatedNavBar.selectedProduct
      (newFeaturesView, featFX) = F.update appConfig (FeaturesActions.NavigationAction navBarAction) productView.featuresView
      switchingProducts         = productView.navBar.selectedProduct == newSelectedProduct
  in
    case switchingProducts of
      True -> ( { productView | navBar = updatedNavBar, featuresView = newFeaturesView }
              , Effects.batch [ Effects.map Actions.NavBarAction navBarFx
                              , Effects.map Actions.FeaturesViewAction featFX
                              ]
              )
      False ->
        PV.init appConfig productView.navBar.products newSelectedProduct
