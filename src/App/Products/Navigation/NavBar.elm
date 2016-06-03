module App.Products.Navigation.NavBar exposing
  ( ProductViewNavBar
  , ProductViewOption (..)
  , init
  , update
  , view
  )

import App.Products.Product                  exposing (Product)
import App.Products.Navigation as Navigation
import Html                                  exposing (Html)
import Html.Attributes                       exposing (attribute, class, classList, href, id)
import Html.Events                           exposing (onClick)
import Http
import Ports exposing (openOAuthWindow)
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

update : Navigation.Msg -> ProductViewNavBar -> (ProductViewNavBar, Cmd Navigation.Msg)
update msg navBar =
  case msg of
    Navigation.SelectFeaturesView         -> ({ navBar | selectedView = FeaturesViewOption } , Cmd.none)
    Navigation.SelectDomainTermsView      -> ({ navBar | selectedView = DomainTermsViewOption } , Cmd.none)
    Navigation.SelectUserRolesView        -> ({ navBar | selectedView = UserRolesViewOption } , Cmd.none)
    Navigation.SetSelectedProduct product -> ({ navBar | selectedProduct = product } , Cmd.none)
    Navigation.ShowCreateNewProductForm   -> ( navBar, Cmd.none )
    Navigation.Login                      -> ( navBar, openOAuthWindow "dummy" )

view : ProductViewNavBar -> Html Navigation.Msg
view navBar =
  NavBar.renderNavBar
    [ renderProductsDropdownItem navBar
    , renderFeaturesItem navBar
    , renderDomainTermsItem navBar
    , renderUserRolesItem navBar
    ]
    [ renderLoginItem ]

renderLoginItem : NavBarItem Navigation.Msg
renderLoginItem =
  { attributes = [ classList [("active", False)] ]
  , html = [ loginLink ]
  }

renderProductsDropdownItem : ProductViewNavBar -> NavBarItem Navigation.Msg
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

renderFeaturesItem : ProductViewNavBar -> NavBarItem Navigation.Msg
renderFeaturesItem navBar =
  { attributes = [ classList [("active", navBar.selectedView == FeaturesViewOption)] ]
  , html = [ featuresLink ]
  }

renderDomainTermsItem : ProductViewNavBar -> NavBarItem Navigation.Msg
renderDomainTermsItem navBar =
  { attributes = [ classList [("active", navBar.selectedView == DomainTermsViewOption)] ]
  , html = [ domainTermsLink ]
  }

renderUserRolesItem : ProductViewNavBar -> NavBarItem Navigation.Msg
renderUserRolesItem navBar =
  { attributes = [ classList [("active", navBar.selectedView == UserRolesViewOption)] ]
  , html = [ userRolesLink ]
  }

renderProductItem : Product -> Html Navigation.Msg
renderProductItem product =
  Html.li [] [ Html.a [ onClick (Navigation.SetSelectedProduct product) ] [ Html.text product.name ] ]

loginLink : Html Navigation.Msg
loginLink =
  let authUrl = Http.url "https://github.com/login/oauth/authorize" [("client_id", "73a5260179f44a8a35ab"), ("scope", "user repo")]
  in
    Html.a [ onClick Navigation.Login ] [ Html.text "Login with GitHub" ]

featuresLink : Html Navigation.Msg
featuresLink = Html.a [ onClick Navigation.SelectFeaturesView ] [ Html.text "Features" ]

domainTermsLink : Html Navigation.Msg
domainTermsLink = Html.a [ onClick Navigation.SelectDomainTermsView ] [ Html.text "DomainTerms" ]

userRolesLink : Html Navigation.Msg
userRolesLink = Html.a [ onClick Navigation.SelectUserRolesView ] [ Html.text "UserRoles" ]
