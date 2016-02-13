module App.Products.Show.View where

import Html                                        exposing (Html)
import App.Products.DomainTerms.Index.View as DTV
import App.Products.Features.Index.View as FV
import App.Products.Show.Actions                   exposing (Action(..))
import App.Products.Show.ViewModel                 exposing (ProductView)
import App.Products.UserRoles.Index.View as URV
import App.Products.Navigation.NavBar as NavBar
import Html.Attributes                       exposing (classList)

view : Signal.Address Action -> ProductView -> Html
view address productView =
  let forwardedAddress = Signal.forwardTo address NavBarAction
      navBar = NavBar.view forwardedAddress productView.navBar
      mainContent = case productView.navBar.selectedView of
                      NavBar.FeaturesViewOption -> renderFeaturesView address productView
                      NavBar.DomainTermsViewOption -> renderDomainTermsView address productView
                      NavBar.UserRolesViewOption -> renderUserRolesView address productView
  in Html.div [] [ navBar, mainContent ]

renderFeaturesView : Signal.Address Action -> ProductView -> Html
renderFeaturesView address productView =
  let signal = (Signal.forwardTo address FeaturesViewAction)
  in
    productViewContainer [ FV.view signal productView.featuresView ]

renderDomainTermsView : Signal.Address Action -> ProductView -> Html
renderDomainTermsView address productView =
  let signal = (Signal.forwardTo address DomainTermsViewAction)
  in
    productViewContainer [ DTV.view signal productView.domainTermsView ]

renderUserRolesView : Signal.Address Action -> ProductView -> Html
renderUserRolesView address productView =
  let signal = (Signal.forwardTo address UserRolesViewAction)
  in
    productViewContainer [ URV.view signal productView.userRolesView ]

productViewContainer : List Html -> Html
productViewContainer content =
  Html.div
  [ classList [("fc-padding--horizontal--medium", True)] ]
  content

