import ProductList as PL exposing (update, init, view)

import Task     exposing (Task)
import Effects  exposing (Never)
import StartApp exposing (start)

productsEndpoint = "http://private-d50ac-featurecreature.apiary-mock.com/products"

app = start
  { init   = PL.init productsEndpoint
  , update = PL.update
  , view   = PL.view
  , inputs = []
  }

main = app.html

port tasks : Signal (Task.Task Never ())
port tasks = app.tasks
