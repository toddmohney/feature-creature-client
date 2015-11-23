module UI.App.Components.ProductPageNavBar where

import Html exposing (Html, Attribute)
import Html.Attributes exposing (attribute, class, classList, href, id)

type alias NavBarItem =
  { attributes : List Attribute
  , html       : Html
  }

renderNavBar : List NavBarItem -> Html
renderNavBar navBarItems =
  Html.nav
    [ classList [("navbar", True), ("navbar-inverse", True)] ]
    [ Html.div
        [ class "container-fluid" ]
        [ navBarHeader
        , renderItems navBarItems
        ]
    ]

renderItems : List NavBarItem -> Html
renderItems items =
  Html.div
    [ classList [("collapse", True), ("navbar-collapse", True)]
    , id "main_nav"
    ]
    [ Html.ul
        [ classList [("nav", True), ("navbar-nav", True)] ]
        (List.map renderItem items)
    ]

renderItem : NavBarItem -> Html
renderItem item =
  Html.li item.attributes [item.html]

navBarHeader : Html
navBarHeader =
  Html.div
    [ class "navbar-header" ]
    [ navBarCollapsibleNavButton
    , navBarBrandButton
    ]

navBarBrandButton : Html
navBarBrandButton =
  Html.a
    [ class "navbar-brand", href "#" ]
    [ Html.text "FeatureCreature" ]

navBarCollapsibleNavButton : Html
navBarCollapsibleNavButton =
  Html.button
    [ attribute "type" "button"
    , attribute "data-toggle" "collapse"
    , attribute "data-target" "#main_nav"
    , attribute "aria-expanded" "false"
    , classList [("navbar-toggle", True), ("collapsed", True)]
    ]
    [ Html.span [ class "icon-bar" ] []
    , Html.span [ class "icon-bar" ] []
    , Html.span [ class "icon-bar" ] []
    ]

