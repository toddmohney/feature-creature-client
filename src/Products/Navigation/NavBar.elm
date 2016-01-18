module Products.Navigation.NavBar where

import Effects                            exposing (Effects)
import Html                               exposing (Html)
import Html.Attributes                    exposing (attribute, class, classList, href, id)
import Html.Events                        exposing (onClick)
import Products.Product                   exposing (Product)
import Products.Navigation as Navigation
import UI.App.Components.NavBar as NavBar exposing (NavBarItem)

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

update : Navigation.Action -> ProductViewNavBar -> (ProductViewNavBar, Effects Navigation.Action)
update action navBar =
  case action of
    Navigation.SelectFeaturesView ->
      ( { navBar | selectedView = FeaturesViewOption }
      , Effects.none
      )

    Navigation.SelectDomainTermsView ->
      ( { navBar | selectedView = DomainTermsViewOption }
      , Effects.none
      )

    Navigation.SelectUserRolesView ->
      ( { navBar | selectedView = UserRolesViewOption }
      , Effects.none
      )

    Navigation.SetSelectedProduct product ->
      ( { navBar | selectedProduct = product }
      , Effects.none
      )

    Navigation.ShowCreateNewProductForm ->
      -- noop, we want someone higher up the chain to react to this effect
      ( navBar, Effects.none )

view : Signal.Address Navigation.Action -> ProductViewNavBar -> Html
view address navBar =
  NavBar.renderNavBar
    [ renderProductsDropdownItem address navBar
    , renderFeaturesItem address navBar
    , renderDomainTermsItem address navBar
    , renderUserRolesItem address navBar
    ]

renderProductsDropdownItem : Signal.Address Navigation.Action -> ProductViewNavBar -> NavBarItem
renderProductsDropdownItem address navBar =
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
        <| List.map (renderProductItem address) navBar.products ++
        [ Html.li [ class "divider", attribute "role" "separator" ] []
        , Html.li [] [ Html.a [ onClick address Navigation.ShowCreateNewProductForm ] [ Html.text "Create New Product" ] ]
        ]
    ]
  }

renderFeaturesItem : Signal.Address Navigation.Action -> ProductViewNavBar -> NavBarItem
renderFeaturesItem address navBar =
  { attributes = [ classList [("active", navBar.selectedView == FeaturesViewOption)] ]
  , html = [ featuresLink address ]
  }

renderDomainTermsItem : Signal.Address Navigation.Action -> ProductViewNavBar -> NavBarItem
renderDomainTermsItem address navBar =
  { attributes = [ classList [("active", navBar.selectedView == DomainTermsViewOption)] ]
  , html = [ domainTermsLink address ]
  }

renderUserRolesItem : Signal.Address Navigation.Action -> ProductViewNavBar -> NavBarItem
renderUserRolesItem address navBar =
  { attributes = [ classList [("active", navBar.selectedView == UserRolesViewOption)] ]
  , html = [ userRolesLink address ]
  }

renderProductItem : Signal.Address Navigation.Action -> Product -> Html
renderProductItem address product =
  Html.li [] [ Html.a [ onClick address (Navigation.SetSelectedProduct product) ] [ Html.text product.name ] ]

featuresLink : Signal.Address Navigation.Action -> Html
featuresLink address = Html.a [ onClick address Navigation.SelectFeaturesView ] [ Html.text "Features" ]

domainTermsLink : Signal.Address Navigation.Action -> Html
domainTermsLink address = Html.a [ onClick address Navigation.SelectDomainTermsView ] [ Html.text "DomainTerms" ]

userRolesLink : Signal.Address Navigation.Action -> Html
userRolesLink address = Html.a [ onClick address Navigation.SelectUserRolesView ] [ Html.text "UserRoles" ]
