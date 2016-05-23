port module Main exposing (..)

import App.App  as App
-- import App.Messages as App
import App.Update  as App
import App.AppConfig      exposing (..)
import Html.App as Html
-- import UI.SyntaxHighlighting exposing (highlightSyntaxMailbox)


main : Program AppConfig
main = Html.programWithFlags
  { init   = App.init
  , update = App.update
  , view   = App.view
  , subscriptions = (\_ -> Sub.none)
  }

-- subscriptions : AppConfig -> Sub App.Msg
-- subscriptions model =
  -- appConfig App.ConfigLoaded

-- port appConfig : (AppConfig -> msg) -> Sub msg

-- port highlightSyntaxPort : Signal (Maybe ())
-- port highlightSyntaxPort = highlightSyntaxMailbox.signal
