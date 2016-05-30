module App.Products.Show.Update exposing ( update )

import App.AppConfig                                  exposing (..)
import App.Products.DomainTerms.Messages as DT
import App.Products.DomainTerms.Index.Update as DT
import App.Products.Features.Messages as F
import App.Products.Features.Index.Update as F
import App.Products.Features.Requests as F
import App.Products.Navigation as Navigation
import App.Products.Navigation.NavBar as NavBar
import App.Products.Product                           exposing (Product)
import App.Products.Messages                          exposing (Msg(..))
import App.Products.Show.ViewModel as PV              exposing (ProductView)
import App.Products.UserRoles.Messages as UR
import App.Products.UserRoles.Index.Update as URV
import App.Search.Types as Search

update : Msg -> ProductView -> AppConfig -> (ProductView, Cmd Msg)
update action productView appConfig =
  case action of
    NavBarAction navBarAction -> handleNavigation appConfig navBarAction productView

    FeaturesViewAction fvAction ->
      let (featView, fvFx) = F.update appConfig fvAction productView.featuresView
      in case fvAction of
        (F.FetchFeaturesSucceeded _ _) ->
          let navBar = productView.navBar
              updatedNavBar = { navBar | selectedView = NavBar.FeaturesViewOption }
          in
            ( { productView | featuresView = featView
                            , navBar = updatedNavBar
              }
              , Cmd.map FeaturesViewAction fvFx
            )

        _ ->
          ( { productView | featuresView = featView }
            , Cmd.map FeaturesViewAction fvFx
          )

    DomainTermsViewAction dtvAction ->
      let (domainTermsView, dtvFx) = DT.update dtvAction productView.domainTermsView appConfig
          newProductView = { productView | domainTermsView = domainTermsView }
      in case dtvAction of
        DT.SearchFeatures query ->
          ( newProductView
          , Cmd.map FeaturesViewAction (searchFeatures appConfig newProductView.product query)
          )

        _ ->
          ( newProductView
          , Cmd.map DomainTermsViewAction dtvFx
          )

    UserRolesViewAction urvAction ->
      let (userRolesView, urvFx) = URV.update urvAction productView.userRolesView appConfig
          newProductView = { productView | userRolesView = userRolesView }
      in case urvAction of
        UR.SearchFeatures query ->
          ( newProductView
          , Cmd.map FeaturesViewAction (searchFeatures appConfig productView.product query)
          )

        _ ->
          ( newProductView
           , Cmd.map UserRolesViewAction urvFx
          )

searchFeatures : AppConfig -> Product -> Search.Query -> Cmd F.Msg
searchFeatures appConfig product query =
  F.getFeaturesList appConfig product (Just query)

handleNavigation : AppConfig -> Navigation.Action -> ProductView -> (ProductView, Cmd Msg)
handleNavigation appConfig navBarAction productView =
  let (updatedNavBar, navBarFx) = NavBar.update navBarAction productView.navBar
      (newFeaturesView, featFX) = F.update appConfig (F.NavigationAction navBarAction) productView.featuresView
      newSelectedProduct        = updatedNavBar.selectedProduct
      switchingProducts         = productView.navBar.selectedProduct == newSelectedProduct
  in
    case switchingProducts of
      True ->
        let model = { productView | navBar = updatedNavBar, featuresView = newFeaturesView }
            cmd = Cmd.batch [ Cmd.map NavBarAction navBarFx , Cmd.map FeaturesViewAction featFX ]
        in
          (model, cmd)
      False ->
        PV.init appConfig productView.navBar.products newSelectedProduct
