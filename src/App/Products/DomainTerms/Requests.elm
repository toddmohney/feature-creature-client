module App.Products.DomainTerms.Requests exposing
  ( createDomainTerm
  , editDomainTerm
  , getDomainTerms
  , removeDomainTerm
  )

import App.AppConfig                       exposing (..)
import App.Products.Product                exposing (Product)
import App.Products.DomainTerms.DomainTerm exposing (DomainTerm)
import App.Products.DomainTerms.Messages   exposing (Msg(..))
import CoreExtensions.Maybe                exposing (fromJust)
import Http                                exposing (Error, Request)
import Json.Encode
import Json.Decode as Json                 exposing ((:=))
import Task                                exposing (Task)
import Utils.Http

getDomainTerms : AppConfig
              -> Product
              -> Cmd Msg
getDomainTerms appConfig product =
  domainTermsUrl appConfig product
    |> Http.get parseDomainTerms
    |> Task.perform FetchDomainTermsFailed FetchDomainTermsSucceeded

createDomainTerm : AppConfig
                -> Product
                -> DomainTerm
                -> Cmd Msg
createDomainTerm appConfig product domainTerm =
  createDomainTermRequest appConfig product domainTerm
    |> Http.send Http.defaultSettings
    |> Http.fromJson parseDomainTerm
    |> Task.perform CreateDomainTermFailed CreateDomainTermSucceeded

editDomainTerm : AppConfig
              -> Product
              -> DomainTerm
              -> Cmd Msg
editDomainTerm appConfig product domainTerm =
  editDomainTermRequest appConfig product domainTerm
    |> Http.send Http.defaultSettings
    |> Http.fromJson parseDomainTerm
    |> Task.perform UpdateDomainTermFailed UpdateDomainTermSucceeded

removeDomainTerm : AppConfig
                -> Product
                -> DomainTerm
                -> Cmd Msg
removeDomainTerm appConfig product domainTerm =
  removeDomainTermRequest appConfig product domainTerm
    |> Http.send Http.defaultSettings
    |> Http.fromJson (Json.succeed domainTerm)
    |> Task.perform DeleteDomainTermFailed DeleteDomainTermSucceeded

removeDomainTermRequest : AppConfig -> Product -> DomainTerm -> Request
removeDomainTermRequest appConfig product domainTerm =
  domainTermUrl appConfig product domainTerm
    |> Utils.Http.jsonDeleteRequest

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
