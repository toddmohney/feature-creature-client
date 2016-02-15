module Utils.Http where

import Http

jsonPostRequest : String -> String -> Http.Request
jsonPostRequest url jsonEncodedRequestBody =
  { verb = "POST"
  , headers = [ ("Content-Type", "application/json") ]
  , url = url
  , body = Http.string jsonEncodedRequestBody
  }

jsonDeleteRequest : String -> String -> Http.Request
jsonDeleteRequest url jsonEncodedRequestBody =
  { verb = "DELETE"
  , headers = [ ("Content-Type", "application/json") ]
  , url = url
  , body = Http.string jsonEncodedRequestBody
  }
