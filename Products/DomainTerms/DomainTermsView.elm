module Products.DomainTerms.DomainTermsView where

import Debug                                  exposing (crash)
import Effects                                exposing (Effects)
import Html                                   exposing (Html)
import Http                                   exposing (Error)
import Json.Decode as Json                    exposing ((:=))
import Products.DomainTerms.DomainTerm as DT  exposing (DomainTerm)
import Products.Product                       exposing (Product)
import Task                                   exposing (Task)

type alias DomainTermsView =
  { product : Product }

type Action = UpdateDomainTerms (Result Error (List DomainTerm))
            | DomainTermsAction DT.Action

init : Product -> (DomainTermsView, Effects Action)
init prod =
  let effects = getDomainTermsList (domainTermsUrl prod)
  in ({ product = prod }, effects)

update : Action -> DomainTermsView -> (DomainTermsView, Effects Action)
update action domainTermsView =
  case action of
    UpdateDomainTerms domainTermsResult ->
      case domainTermsResult of
        Ok domainTermList ->
          let prod = domainTermsView.product
              updatedProduct = { prod | domainTerms <- domainTermList }
              newView = { domainTermsView | product <- updatedProduct }
          in (newView, Effects.none)
        Err _ -> crash "Something went wrong!"

view : Signal.Address Action -> DomainTermsView -> Html
view address domainTermsView =
  let signal = Signal.forwardTo address DomainTermsAction
      domainTerms = domainTermsView.product.domainTerms
  in Html.div [] (List.map (DT.view signal) domainTerms)

getDomainTermsList : String -> Effects Action
getDomainTermsList url =
  Http.get parseDomainTerms url
   |> Task.toResult
   |> Task.map UpdateDomainTerms
   |> Effects.task

parseDomainTerms : Json.Decoder (List DomainTerm)
parseDomainTerms = parseDomainTerm |> Json.list

parseDomainTerm : Json.Decoder DomainTerm
parseDomainTerm =
  Json.object2 DomainTerm
    ("title"       := Json.string)
    ("description" := Json.string)

domainTermsUrl : Product -> String
domainTermsUrl prod = "http://localhost:8081/products/" ++ (toString prod.id) ++ "/domain-terms"
