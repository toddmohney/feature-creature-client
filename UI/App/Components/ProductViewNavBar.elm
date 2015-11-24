module UI.App.Components.ProductViewNavBar where

import Effects exposing (Effects)
import Html exposing (Html)
import Html.Attributes exposing (attribute, class, classList, href, id)
import Html.Events exposing (onClick)
import Products.Product exposing (Product)
import Products.Navigation as Nav
import UI.App.Components.NavBar as NavBar exposing (NavBarItem)

type alias ProductViewNavBar =
  { products        : List Product
  , selectedProduct : Product
  , selectedView    : ProductViewOption
  }

type ProductViewOption = FeaturesViewOption
                       | DomainTermsViewOption

init : List Product -> Product -> ProductViewNavBar
init products selectedProduct =
  { products = products
  , selectedProduct = selectedProduct
  , selectedView = FeaturesViewOption
  }

update : Nav.Action -> ProductViewNavBar -> (ProductViewNavBar, Effects Nav.Action)
update action navBar =
  case action of
    Nav.SelectFeaturesView ->
      ( { navBar | selectedView <- FeaturesViewOption }
      , Effects.none
      )

    Nav.SelectDomainTermsView ->
      ( { navBar | selectedView <- DomainTermsViewOption }
      , Effects.none
      )

    Nav.SetSelectedProduct product ->
      ( { navBar | selectedProduct <- product }
      , Effects.none
      )

    Nav.ShowCreateNewProductForm ->
      -- noop, we want someone higher up the chain to react to this effect
      ( navBar, Effects.none )

view : Signal.Address Nav.Action -> ProductViewNavBar -> Html
view address navBar =
  NavBar.renderNavBar
    [ renderProductsDropdownItem address navBar
    , renderFeaturesItem address navBar
    , renderDomainTermsItem address navBar
    ]

renderProductsDropdownItem : Signal.Address Nav.Action -> ProductViewNavBar -> NavBarItem
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
        , Html.li [] [ Html.a [ onClick address Nav.ShowCreateNewProductForm ] [ Html.text "Create New Product" ] ]
        ]
    ]
  }

renderFeaturesItem : Signal.Address Nav.Action -> ProductViewNavBar -> NavBarItem
renderFeaturesItem address navBar =
  { attributes = [ classList [("active", navBar.selectedView == FeaturesViewOption)] ]
  , html = [ featuresLink address ]
  }

renderDomainTermsItem : Signal.Address Nav.Action -> ProductViewNavBar -> NavBarItem
renderDomainTermsItem address navBar =
  { attributes = [ classList [("active", navBar.selectedView == DomainTermsViewOption)] ]
  , html = [ domainTermsLink address ]
  }

renderProductItem : Signal.Address Nav.Action -> Product -> Html
renderProductItem address product =
  Html.li [] [ Html.a [ onClick address (Nav.SetSelectedProduct product) ] [ Html.text product.name ] ]

featuresLink : Signal.Address Nav.Action -> Html
featuresLink address = Html.a [ onClick address Nav.SelectFeaturesView ] [ Html.text "Features" ]

domainTermsLink : Signal.Address Nav.Action -> Html
domainTermsLink address = Html.a [ onClick address Nav.SelectDomainTermsView ] [ Html.text "DomainTerms" ]
