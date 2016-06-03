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
update msg productView appConfig =
  case msg of
    NavBarMsg navBarMsg -> handleNavigation appConfig navBarMsg productView

    FeaturesViewMsg fvMsg ->
      let (featView, fvFx) = F.update appConfig fvMsg productView.featuresView
      in case fvMsg of
        (F.FetchFeaturesSucceeded _ _) ->
          let navBar = productView.navBar
              updatedNavBar = { navBar | selectedView = NavBar.FeaturesViewOption }
          in
            ( { productView | featuresView = featView
                            , navBar = updatedNavBar
              }
              , Cmd.map FeaturesViewMsg fvFx
            )

        _ ->
          ( { productView | featuresView = featView }
            , Cmd.map FeaturesViewMsg fvFx
          )

    DomainTermsViewMsg dtvMsg ->
      let (domainTermsView, dtvFx) = DT.update dtvMsg productView.domainTermsView appConfig
          newProductView = { productView | domainTermsView = domainTermsView }
      in case dtvMsg of
        DT.SearchFeatures query ->
          ( newProductView
          , Cmd.map FeaturesViewMsg (searchFeatures appConfig newProductView.product query)
          )

        _ ->
          ( newProductView
          , Cmd.map DomainTermsViewMsg dtvFx
          )

    UserRolesViewMsg urvMsg ->
      let (userRolesView, urvFx) = URV.update urvMsg productView.userRolesView appConfig
          newProductView = { productView | userRolesView = userRolesView }
      in case urvMsg of
        UR.SearchFeatures query ->
          ( newProductView
          , Cmd.map FeaturesViewMsg (searchFeatures appConfig productView.product query)
          )

        _ ->
          ( newProductView
           , Cmd.map UserRolesViewMsg urvFx
          )

searchFeatures : AppConfig -> Product -> Search.Query -> Cmd F.Msg
searchFeatures appConfig product query =
  F.getFeaturesList appConfig product (Just query)

handleNavigation : AppConfig -> Navigation.Msg -> ProductView -> (ProductView, Cmd Msg)
handleNavigation appConfig navBarMsg productView =
  let (updatedNavBar, navBarFx) = NavBar.update navBarMsg productView.navBar
      (newFeaturesView, featFX) = F.update appConfig (F.NavigationMsg navBarMsg) productView.featuresView
      newSelectedProduct        = updatedNavBar.selectedProduct
      switchingProducts         = productView.navBar.selectedProduct == newSelectedProduct
  in
    case switchingProducts of
      True ->
        let model = { productView | navBar = updatedNavBar, featuresView = newFeaturesView }
            cmd = Cmd.batch [ Cmd.map NavBarMsg navBarFx , Cmd.map FeaturesViewMsg featFX ]
        in
          (model, cmd)
      False ->
        PV.init appConfig productView.navBar.products newSelectedProduct
