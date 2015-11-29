module UI.SyntaxHighlighting where

type alias HighlightSyntaxMailbox =
  { address : Signal.Address (Maybe ())
  , signal : Signal (Maybe ())
  }

type Action = HighlightSyntax

highlightSyntaxMailbox : HighlightSyntaxMailbox
highlightSyntaxMailbox = Signal.mailbox Nothing

