port module Main exposing (..)

import App.App  as App
-- import App.Messages as App
import App.Update  as App
-- import App.AppConfig      exposing (..)
-- import Html               exposing (..)
import Html.App as Html
-- import UI.SyntaxHighlighting exposing (highlightSyntaxMailbox)


-- app : Program App.App
-- app = Html.program
  -- { init   = App.init
  -- , update = App.update
  -- , view   = App.view
  -- , subscriptions = [(Sub.map App.ConfigLoaded initAppConfig)]
  -- }

main : Program Never
main = Html.program
  { init   = App.init
  , update = App.update
  , view   = App.view
  , subscriptions = (\_ -> Sub.none)
  }

-- port tasks : Signal (Task.Task Never ())
-- port tasks = app.tasks

-- port initAppConfig : Signal AppConfig
-- port initAppConfig : (AppConfig -> msg) -> Sub msg

-- port highlightSyntaxPort : Signal (Maybe ())
-- port highlightSyntaxPort = highlightSyntaxMailbox.signal
