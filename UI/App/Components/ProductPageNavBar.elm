module UI.App.Components.ProductPageNavBar where

import Effects exposing (Effects)
import Html exposing (Html)
import Html.Attributes exposing (attribute, class, classList, href, id)
import Html.Events exposing (onClick)
import Products.Product exposing (Product)
import UI.App.Components.NavBar as NavBar exposing (NavBarItem)

type alias ProductPageNavBar =
  { products        : List Product
  , selectedProduct : Product
  , selectedView    : ProductViewOption
  }

type Action = SelectFeaturesView
            | SelectDomainTermsView
            | SetSelectedProduct Product

type ProductViewOption = FeaturesViewOption
                       | DomainTermsViewOption

init : List Product -> Product -> ProductPageNavBar
init products selectedProduct =
  { products = products
  , selectedProduct = selectedProduct
  , selectedView = FeaturesViewOption
  }

update : Action -> ProductPageNavBar -> (ProductPageNavBar, Effects Action)
update action navBar =
  case action of
    SelectFeaturesView ->
      ( { navBar | selectedView <- FeaturesViewOption }
      , Effects.none
      )

    SelectDomainTermsView ->
      ( { navBar | selectedView <- DomainTermsViewOption }
      , Effects.none
      )

    SetSelectedProduct product ->
      ( { navBar | selectedProduct <- product }
      , Effects.none
      )

view : Signal.Address Action -> ProductPageNavBar -> Html
view address navBar =
  NavBar.renderNavBar
    [ renderProductsDropdownItem address navBar
    , renderFeaturesItem address navBar
    , renderDomainTermsItem address navBar
    ]

renderProductsDropdownItem : Signal.Address Action -> ProductPageNavBar -> NavBarItem
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
        , Html.li [] [ Html.a [ href "#" ] [ Html.text "Create New Product" ] ]
        ]
    ]
  }

renderFeaturesItem : Signal.Address Action -> ProductPageNavBar -> NavBarItem
renderFeaturesItem address navBar =
  { attributes = [ classList [("active", navBar.selectedView == FeaturesViewOption)] ]
  , html = [ featuresLink address ]
  }

renderDomainTermsItem : Signal.Address Action -> ProductPageNavBar -> NavBarItem
renderDomainTermsItem address navBar =
  { attributes = [ classList [("active", navBar.selectedView == DomainTermsViewOption)] ]
  , html = [ domainTermsLink address ]
  }

renderProductItem : Signal.Address Action -> Product -> Html
renderProductItem address product =
  Html.li [] [ Html.a [ onClick address (SetSelectedProduct product) ] [ Html.text product.name ] ]

featuresLink : Signal.Address Action -> Html
featuresLink address = Html.a [ onClick address SelectFeaturesView ] [ Html.text "Features" ]

domainTermsLink : Signal.Address Action -> Html
domainTermsLink address = Html.a [ onClick address SelectDomainTermsView ] [ Html.text "DomainTerms" ]
