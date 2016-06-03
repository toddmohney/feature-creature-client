module App.Products.Show.ViewModel exposing
  ( ProductView
  , init
  )

import App.AppConfig                                   exposing (..)
import App.Products.DomainTerms.Index.ViewModel as DTV exposing (DomainTermsView)
import App.Products.Features.Index.ViewModel as FV     exposing (FeaturesView)
import App.Products.Product                            exposing (Product)
import App.Products.Messages                           exposing (Msg(..))
import App.Products.UserRoles.Index.ViewModel as URV   exposing (UserRolesView)
import App.Products.Navigation.NavBar as NavBar        exposing (ProductViewNavBar)

type alias ProductView =
  { product         : Product
  , navBar          : ProductViewNavBar
  , featuresView    : FeaturesView
  , domainTermsView : DomainTermsView
  , userRolesView   : UserRolesView
  }

init : AppConfig -> List Product -> Product -> (ProductView, Cmd Msg)
init appConfig products selectedProduct =
  let (featView, featuresViewCmd)       = FV.init appConfig selectedProduct
      (domainTermsView, domainTermsCmd) = DTV.init selectedProduct appConfig
      (userRolesView, userRolesCmd)     = URV.init selectedProduct appConfig
      productView = { product          = selectedProduct
                    , navBar           = NavBar.init products selectedProduct
                    , featuresView     = featView
                    , domainTermsView  = domainTermsView
                    , userRolesView    = userRolesView
                    }
  in ( productView
     , Cmd.batch [
         Cmd.map FeaturesViewMsg featuresViewCmd
       , Cmd.map DomainTermsViewMsg domainTermsCmd
       , Cmd.map UserRolesViewMsg userRolesCmd
       ]
     )
