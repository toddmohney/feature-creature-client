module Utils.Http where

import Http

jsonPostRequest : String -> String -> Http.Request
jsonPostRequest url jsonEncodedRequestBody =
  { verb = "POST"
  , headers = [ ("Origin", "http://localhost:8000")
              , ("Access-Control-Request-Method", "POST")
              , ("Content-Type", "application/json")
              ]
  , url = url
  , body = Http.string jsonEncodedRequestBody
  }
