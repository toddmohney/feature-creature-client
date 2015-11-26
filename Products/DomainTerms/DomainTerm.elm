module Products.DomainTerms.DomainTerm where

import Json.Encode
import Json.Decode as Json                   exposing ((:=))

type alias DomainTerm =
  { title : String
  , description : String
  }

init : DomainTerm
init = { title = ""
       , description = ""
       }

encodeDomainTerm : DomainTerm -> String
encodeDomainTerm domainTerm =
  Json.Encode.encode 0
    <| Json.Encode.object
        [ ("title",       Json.Encode.string domainTerm.title)
        , ("description", Json.Encode.string domainTerm.description)
        ]

parseDomainTerms : Json.Decoder (List DomainTerm)
parseDomainTerms = parseDomainTerm |> Json.list

parseDomainTerm : Json.Decoder DomainTerm
parseDomainTerm =
  Json.object2 DomainTerm
    ("title"       := Json.string)
    ("description" := Json.string)
