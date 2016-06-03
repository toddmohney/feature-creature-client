port module Ports exposing
  ( highlightSyntax
  , openOAuthWindow
  , receiveAuthorizationCode
  )

-- outbound messages
port highlightSyntax : String -> Cmd msg
port openOAuthWindow : String -> Cmd msg

-- inbound messages
port receiveAuthorizationCode : (String -> msg) -> Sub msg
