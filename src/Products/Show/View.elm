module Products.Show.View where

import Html                                        exposing (Html)
import Products.DomainTerms.Index.View as DTV
import Products.Features.Index.View as FV
import Products.Show.Actions exposing (Action(..))
import Products.Show.Model exposing (ProductView)
import Products.UserRoles.UserRolesView as URV
import UI.App.Components.ProductViewNavBar as PVNB

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
