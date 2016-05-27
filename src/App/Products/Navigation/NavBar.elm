module App.Products.Navigation.NavBar exposing (..)

import Html                                  exposing (Html)
import Html.Attributes                       exposing (attribute, class, classList, href, id)
import Html.Events                           exposing (onClick)
import App.Products.Product                  exposing (Product)
import App.Products.Navigation as Navigation
import UI.App.Components.NavBar as NavBar    exposing (NavBarItem)

type alias ProductViewNavBar =
  { products        : List Product
  , selectedProduct : Product
  , selectedView    : ProductViewOption
  }

type ProductViewOption = FeaturesViewOption
                       | DomainTermsViewOption
                       | UserRolesViewOption

init : List Product -> Product -> ProductViewNavBar
init products selectedProduct =
  { products = products
  , selectedProduct = selectedProduct
  , selectedView = FeaturesViewOption
  }

update : Navigation.Action -> ProductViewNavBar -> (ProductViewNavBar, Cmd Navigation.Action)
update action navBar =
  case action of
    Navigation.SelectFeaturesView         -> ({ navBar | selectedView = FeaturesViewOption } , Cmd.none)
    Navigation.SelectDomainTermsView      -> ({ navBar | selectedView = DomainTermsViewOption } , Cmd.none)
    Navigation.SelectUserRolesView        -> ({ navBar | selectedView = UserRolesViewOption } , Cmd.none)
    Navigation.SetSelectedProduct product -> ({ navBar | selectedProduct = product } , Cmd.none)
    Navigation.ShowCreateNewProductForm ->
      -- noop, we want someone higher up the chain to react to this effect
      ( navBar, Cmd.none )

view : ProductViewNavBar -> Html Navigation.Action
view navBar =
  NavBar.renderNavBar
    [ renderProductsDropdownItem navBar
    , renderFeaturesItem navBar
    , renderDomainTermsItem navBar
    , renderUserRolesItem navBar
    ]

renderProductsDropdownItem : ProductViewNavBar -> NavBarItem Navigation.Action
renderProductsDropdownItem navBar =
  { attributes = [ class "dropdown" ]
  , html =
    [ Html.a
        [ class "dropdown-toggle"
        , attribute "data-toggle" "dropdown"
        , attribute "role" "button"
        ]
        [ Html.text navBar.selectedProduct.name
        , Html.span [ class "caret" ] []
        ]
    , Html.ul [ class "dropdown-menu" ]
        <| List.map (renderProductItem) navBar.products ++
        [ Html.li [ class "divider", attribute "role" "separator" ] []
        , Html.li [] [ Html.a [ onClick Navigation.ShowCreateNewProductForm ] [ Html.text "Create New Product" ] ]
        ]
    ]
  }

renderFeaturesItem : ProductViewNavBar -> NavBarItem Navigation.Action
renderFeaturesItem navBar =
  { attributes = [ classList [("active", navBar.selectedView == FeaturesViewOption)] ]
  , html = [ featuresLink ]
  }

renderDomainTermsItem : ProductViewNavBar -> NavBarItem Navigation.Action
renderDomainTermsItem navBar =
  { attributes = [ classList [("active", navBar.selectedView == DomainTermsViewOption)] ]
  , html = [ domainTermsLink ]
  }

renderUserRolesItem : ProductViewNavBar -> NavBarItem Navigation.Action
renderUserRolesItem navBar =
  { attributes = [ classList [("active", navBar.selectedView == UserRolesViewOption)] ]
  , html = [ userRolesLink ]
  }

renderProductItem : Product -> Html Navigation.Action
renderProductItem product =
  Html.li [] [ Html.a [ onClick (Navigation.SetSelectedProduct product) ] [ Html.text product.name ] ]

featuresLink : Html Navigation.Action
featuresLink = Html.a [ onClick Navigation.SelectFeaturesView ] [ Html.text "Features" ]

domainTermsLink : Html Navigation.Action
domainTermsLink = Html.a [ onClick Navigation.SelectDomainTermsView ] [ Html.text "DomainTerms" ]

userRolesLink : Html Navigation.Action
userRolesLink = Html.a [ onClick Navigation.SelectUserRolesView ] [ Html.text "UserRoles" ]
