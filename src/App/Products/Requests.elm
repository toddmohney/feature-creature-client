module App.Products.Requests exposing ( createProduct, getProducts )

import App.AppConfig             exposing (..)
import App.Products.Product as P exposing (Product, RepositoryState (..))
import Json.Encode
import Json.Decode as Json       exposing ((:=))
import Http as Http              exposing (..)
import Task as Task              exposing (..)
import Utils.Http

getProducts : AppConfig -> (Result Error (List Product) -> a) -> Effects a
getProducts appConfig action =
  Http.get parseProducts (productsUrl appConfig)
    |> Task.toResult
    |> Task.map action
    |> Effects.task

createProduct : AppConfig -> Product -> (Result Error Product -> a) -> Effects a
createProduct appConfig newProduct action =
  let request = Utils.Http.jsonPostRequest (productsUrl appConfig) (encodeProduct newProduct)
  in
    Http.send Http.defaultSettings request
      |> Http.fromJson parseProduct
      |> Task.toResult
      |> Task.map action
      |> Effects.task

parseProducts : Json.Decoder (List Product)
parseProducts = parseProduct |> Json.list

parseProduct : Json.Decoder Product
parseProduct =
  Json.object5
    P.init'
    ("productId"   := Json.int)
    ("productName" := Json.string)
    ("repoUrl"     := Json.string)
    (("repoState"   := Json.string) `Json.andThen` decodeState)
    ("repoError"   := nullOr Json.string)

decodeState : String -> Json.Decoder RepositoryState
decodeState state = Json.succeed (repoState state)

repoState : String -> RepositoryState
repoState state =
  case state of
    "Ready"   -> Ready
    "Unready" -> Unready
    _         -> Error

nullOr : Json.Decoder a -> Json.Decoder (Maybe a)
nullOr decoder =
  Json.oneOf
    [ Json.null Nothing
    , Json.map Just decoder
    ]

encodeProduct : Product -> String
encodeProduct product =
  Json.Encode.encode 0
    <| Json.Encode.object
        [ ("productName",    Json.Encode.string product.name)
        , ("repoUrl", Json.Encode.string product.repoUrl)
        ]

productsUrl : AppConfig -> String
productsUrl appConfig = appConfig.apiPath ++ "/products"
