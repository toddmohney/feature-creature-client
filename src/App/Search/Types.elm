module App.Search.Types exposing ( Query )

type alias Query =
  { datatype : String
  , term : String
  }
