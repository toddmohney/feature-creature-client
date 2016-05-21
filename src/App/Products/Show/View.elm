module App.Products.Show.View exposing (..)

import Html                                        exposing (Html)
import Html.App as Html
import App.Products.DomainTerms.Index.View as DTV
import App.Products.Features.Index.View as FV
import App.Products.Messages                       exposing (Msg(..))
import App.Products.Show.ViewModel                 exposing (ProductView)
import App.Products.UserRoles.Index.View as URV
import App.Products.Navigation.NavBar as NavBar
import Html.Attributes                       exposing (classList)

view : ProductView -> Html Msg
view productView =
  let navBar = Html.map NavBarAction (NavBar.view productView.navBar)
      mainContent = case productView.navBar.selectedView of
                      NavBar.FeaturesViewOption -> renderFeaturesView productView
                      NavBar.DomainTermsViewOption -> renderDomainTermsView productView
                      NavBar.UserRolesViewOption -> renderUserRolesView productView
  in
    Html.div [] [ navBar, mainContent ]

renderFeaturesView : ProductView -> Html Msg
renderFeaturesView productView =
  Html.map FeaturesViewAction (productViewContainer [ FV.view productView.featuresView ])

renderDomainTermsView : ProductView -> Html Msg
renderDomainTermsView productView =
  Html.map DomainTermsViewAction (productViewContainer [ DTV.view productView.domainTermsView ])

renderUserRolesView : ProductView -> Html Msg
renderUserRolesView productView =
  Html.map UserRolesViewAction (productViewContainer [ URV.view productView.userRolesView ])

productViewContainer : List (Html a) -> Html a
productViewContainer content =
  Html.div
    [ classList [("fc-padding--horizontal--medium", True)] ]
    content

