module App.Products.DomainTerms.Requests exposing
  ( createDomainTerm
  , editDomainTerm
  , getDomainTerms
  , removeDomainTerm
  )

import App.AppConfig                       exposing (..)
import App.Products.Product                exposing (Product)
import App.Products.DomainTerms.DomainTerm exposing (DomainTerm)
import CoreExtensions.Maybe                exposing (fromJust)
import Http                                exposing (Error, Request)
import Json.Encode
import Json.Decode as Json                 exposing ((:=))
import Task                                exposing (Task)
import Utils.Http

getDomainTerms : AppConfig
              -> Product
              -> (Result Error (List DomainTerm) -> a)
              -> Effects a
getDomainTerms appConfig product action =
  Http.get parseDomainTerms (domainTermsUrl appConfig product)
   |> Task.toResult
   |> Task.map action
   |> Effects.task

createDomainTerm : AppConfig
                -> Product
                -> DomainTerm
                -> (Result Error DomainTerm -> a)
                -> Effects a
createDomainTerm appConfig product domainTerm action =
  let request = createDomainTermRequest appConfig product domainTerm
  in Http.send Http.defaultSettings request
     |> Http.fromJson parseDomainTerm
     |> Task.toResult
     |> Task.map action
     |> Effects.task

editDomainTerm : AppConfig
              -> Product
              -> DomainTerm
              -> (Result Error DomainTerm -> a)
              -> Effects a
editDomainTerm appConfig product domainTerm action =
  let request = editDomainTermRequest appConfig product domainTerm
  in Http.send Http.defaultSettings request
     |> Http.fromJson parseDomainTerm
     |> Task.toResult
     |> Task.map action
     |> Effects.task

removeDomainTerm : AppConfig
                -> Product
                -> DomainTerm
                -> (Result Error DomainTerm -> a)
                -> Effects a
removeDomainTerm appConfig product domainTerm action =
  let request = removeDomainTermRequest appConfig product domainTerm
  in
    Http.send Http.defaultSettings request
      |> Http.fromJson (Json.succeed domainTerm)
      |> Task.toResult
      |> Task.map action
      |> Effects.task

removeDomainTermRequest : AppConfig -> Product -> DomainTerm -> Request
removeDomainTermRequest appConfig product domainTerm =
  Utils.Http.jsonDeleteRequest
    <| domainTermUrl appConfig product domainTerm

createDomainTermRequest : AppConfig -> Product -> DomainTerm -> Request
createDomainTermRequest appConfig product domainTerm =
  Utils.Http.jsonPostRequest
    (domainTermsUrl appConfig product)
    (encodeDomainTerm domainTerm)

editDomainTermRequest : AppConfig -> Product -> DomainTerm -> Request
editDomainTermRequest appConfig product domainTerm =
  Utils.Http.jsonPutRequest
    (domainTermUrl appConfig product domainTerm)
    (encodeDomainTerm domainTerm)

domainTermsUrl : AppConfig -> Product -> String
domainTermsUrl appConfig prod =
  appConfig.apiPath
  ++ "/products/"
  ++ (toString prod.id)
  ++ "/domain-terms"

domainTermUrl : AppConfig -> Product -> DomainTerm -> String
domainTermUrl appConfig prod domainTerm =
  appConfig.apiPath
  ++ "/products/"
  ++ (toString prod.id)
  ++ "/domain-terms/"
  ++ (toString (fromJust domainTerm.id))

encodeDomainTerm : DomainTerm -> String
encodeDomainTerm domainTerm =
  case domainTerm.id of
    Nothing -> encodeWithoutId domainTerm
    Just id -> encodeWithId domainTerm

encodeWithoutId : DomainTerm -> String
encodeWithoutId domainTerm =
  Json.Encode.encode 0
    <| Json.Encode.object
        [ ("title",       Json.Encode.string domainTerm.title)
        , ("description", Json.Encode.string domainTerm.description)
        ]

encodeWithId : DomainTerm -> String
encodeWithId domainTerm =
  Json.Encode.encode 0
    <| Json.Encode.object
        [ ("id",          Json.Encode.int (fromJust domainTerm.id))
        , ("title",       Json.Encode.string domainTerm.title)
        , ("description", Json.Encode.string domainTerm.description)
        ]

parseDomainTerms : Json.Decoder (List DomainTerm)
parseDomainTerms = parseDomainTerm |> Json.list

parseDomainTerm : Json.Decoder DomainTerm
parseDomainTerm =
  Json.object3 DomainTerm
    (Json.maybe ("id"   := Json.int))
    ("title"       := Json.string)
    ("description" := Json.string)
