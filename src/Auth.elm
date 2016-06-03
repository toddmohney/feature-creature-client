module Auth exposing
  ( OAuth
  , Msg (..)
  )

type Msg = AuthorizationCodeReceived String

type alias OAuth = { authorizationCode : String }
