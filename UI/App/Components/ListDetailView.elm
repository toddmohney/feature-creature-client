module UI.App.Components.ListDetailView
  ( listDetailView
  ) where

import Html exposing (Html)
import Html.Attributes exposing (class)

listDetailView : List Html -> List Html -> Html
listDetailView listHtml detailHtml =
  Html.div
    [ class "clearfix" ]
    [ Html.div [ class "pull-left" ] listHtml
    , Html.div [ class "pull-right" ] detailHtml
    ]
