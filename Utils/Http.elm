module Utils.Http where

import Http

jsonPostRequest : String -> String -> Http.Request
jsonPostRequest url jsonEncodedRequestBody =
  { verb = "POST"
  , headers = [ ("Content-Type", "application/json") ]
  , url = url
  , body = Http.string jsonEncodedRequestBody
  }
