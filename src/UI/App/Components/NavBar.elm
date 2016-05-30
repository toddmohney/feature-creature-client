module UI.App.Components.NavBar exposing (..)

import Html exposing (Html, Attribute)
import Html.Attributes exposing (attribute, class, classList, href, id)

type alias NavBarItem a =
  { attributes : List (Attribute a)
  , html       : List (Html a)
  }

renderNavBar : List (NavBarItem a) -> Html a
renderNavBar navBarItems =
  Html.nav
    [ classList [("navbar", True), ("navbar-inverse", True)] ]
    [ Html.div
        [ class "container-fluid" ]
        [ navBarHeader
        , renderItems navBarItems
        ]
    ]

renderItems : List (NavBarItem a) -> Html a
renderItems items =
  Html.div
    [ classList [("collapse", True), ("navbar-collapse", True)]
    , id "main_nav"
    ]
    [ Html.ul
        [ classList [("nav", True), ("navbar-nav", True)] ]
        (List.map renderItem items)
    ]

renderItem : NavBarItem a -> Html a
renderItem item =
  Html.li item.attributes item.html

navBarHeader : Html a
navBarHeader =
  Html.div
    [ class "navbar-header" ]
    [ navBarCollapsibleNavButton
    , navBarBrandButton
    ]

navBarBrandButton : Html a
navBarBrandButton =
  Html.a
    [ class "navbar-brand", href "#" ]
    [ Html.text "FeatureCreature" ]

navBarCollapsibleNavButton : Html a
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

