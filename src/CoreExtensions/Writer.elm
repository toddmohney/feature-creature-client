module CoreExtensions.Writer where

{-| Example Usage:

writerTest : Int -> Writer Int String
writerTest num =
  { output = (num + 4)
  , log = "I'm a crazy logger! "
  }

testIt : Writer Int String
testIt = (writerTest 4) `andThen` writerTest `andThen` writerTest

testIt' : (Int, String)
testIt'= runWriter <| (writerTest 4) >>= writerTest >>= writerTest

-}

type alias Writer a appendable =
  { output : a
  , log : appendable
  }

(>>=) : Writer a appendable -> (a -> Writer a appendable) -> Writer a appendable
(>>=) = andThen

andThen : Writer a appendable -> (a -> Writer a appendable) -> Writer a appendable
andThen { output, log } f =
  let (a',w') = runWriter (f output)
  in { output = a'
     , log = log ++ w'
     }

runWriter : Writer a w -> (a, w)
runWriter { output, log } = (output, log)


