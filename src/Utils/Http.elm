module Utils.Http exposing (..)

import Http

jsonPostRequest : String -> String -> Http.Request
jsonPostRequest url jsonEncodedRequestBody =
  { verb = "POST"
  , headers = [ ("Content-Type", "application/json") ]
  , url = url
  , body = Http.string jsonEncodedRequestBody
  }

jsonPutRequest : String -> String -> Http.Request
jsonPutRequest url jsonEncodedRequestBody =
  { verb = "PUT"
  , headers = [ ("Content-Type", "application/json") ]
  , url = url
  , body = Http.string jsonEncodedRequestBody
  }

jsonDeleteRequest : String -> Http.Request
jsonDeleteRequest url =
  { verb = "DELETE"
  , headers = [ ("Content-Type", "application/json") ]
  , url = url
  , body = Http.empty
  }
