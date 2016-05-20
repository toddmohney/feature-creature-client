module UI.App.Components.ListDetailView exposing ( listDetailView )

import Html exposing (Html)
import Html.Attributes exposing (class, style)

listDetailView : List Html -> List Html -> Html
listDetailView listHtml detailHtml =
  Html.div
    [ class "clearfix" ]
    [ Html.div [ class "pull-left", style [ ("width", "33%"), ("padding-right", "10px") ] ] listHtml
    , Html.div [ class "pull-right", style [ ("width", "67%") ] ] detailHtml
    ]
