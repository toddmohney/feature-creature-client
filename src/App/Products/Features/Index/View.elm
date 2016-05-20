module App.Products.Features.Index.View exposing (..)

import App.Products.Features.Feature as F      exposing (Feature)
import App.Products.Features.FeatureList as FL exposing (FeatureList)
import App.Products.Features.Index.Actions     exposing (Action(..))
import App.Products.Features.Index.ViewModel   exposing (FeaturesView)
import App.Products.Product                    exposing (Product, RepositoryState (..))
import App.Search.Types                        exposing (..)
import Data.External                           exposing (External(..))
import Html                                    exposing (..)
import Html.Attributes                         exposing (classList)
import Html.Events                             exposing (onClick)
import UI.App.Components.ListDetailView as UI
import UI.App.Primitives.Buttons as UI

view : Signal.Address Action -> FeaturesView -> Html
view address featuresView =
  let product     = featuresView.product
      featureList = product.featureList
  in case product.repoState of
      Error   -> renderProductError product
      Unready -> renderProductUnready
      Ready   -> renderFeatureList address featuresView featureList

renderProductError : Product -> Html
renderProductError product =
  let message = "There's a problem with this product " ++ (Maybe.withDefault "" product.repoError)
  in Html.div [] [ text message ]

renderProductUnready : Html
renderProductUnready =
  let message = "We're still working on creating your stuff. Please, come back in a minute!"
  in Html.div [] [ text message ]

renderFeatureList : Signal.Address Action -> FeaturesView -> External FL.FeatureList -> Html
renderFeatureList address featuresView featureList =
  case featureList of
    NotLoaded           -> Html.div [] [ text "Loading feature list..." ]
    LoadedWithError err -> Html.div [] [ text err ]
    Loaded featureList  -> featureListHtml address featuresView featureList

featureListHtml : Signal.Address Action -> FeaturesView -> FeatureList -> Html
featureListHtml address featuresView featureList =
  let featureListAddress = Signal.forwardTo address FeatureListAction
      selectedFeature = featuresView.selectedFeature
      listHtml = [ FL.render featureListAddress featureList selectedFeature ]
  in
    case featuresView.currentSearchTerm of
      Nothing ->
        listDetailViewContainer
          <| UI.listDetailView listHtml
          <| featureHtml selectedFeature
      Just query ->
        let listHtmlWithSearchFilterIndicator = (renderCurrentSearchTerm query address) :: listHtml
        in
          listDetailViewContainer
            <| UI.listDetailView listHtmlWithSearchFilterIndicator
            <| featureHtml selectedFeature

featureHtml : Maybe Feature -> List Html
featureHtml selectedFeature =
  case selectedFeature of
    Nothing      -> []
    Just feature ->
      [ selectedFeatureContainer [ (selectedFeatureUI feature) , (featureUI feature) ] ]

selectedFeatureContainer : List Html -> Html
selectedFeatureContainer content =
  Html.div [] content

selectedFeatureUI : Feature -> Html
selectedFeatureUI feature =
  Html.div
  [ (classList [ ("well", True), ("well-sm", True) ]) ]
  [ Html.text feature.featureID ]

featureUI : Feature -> Html
featureUI = F.view

listDetailViewContainer : Html -> Html
listDetailViewContainer listDetailView =
  Html.div [] [ listDetailView ]

renderCurrentSearchTerm : Query -> Signal.Address Action -> Html
renderCurrentSearchTerm query address =
  Html.div
  [ (classList [ ("well", True), ("well-sm", True) ]) ]
  [ (Html.text ("Filtered by: " ++ query.datatype ++ ": " ++ query.term ++ " "))
  , (UI.secondaryBtn [(onClick address RequestFeatures)] "Clear")
  ]
