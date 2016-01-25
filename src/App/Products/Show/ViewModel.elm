module App.Products.Show.ViewModel where

import App.AppConfig                                   exposing (..)
import Effects                                         exposing (Effects)
import App.Products.DomainTerms.Index.ViewModel as DTV exposing (DomainTermsView)
import App.Products.Features.Index.ViewModel as FV     exposing (FeaturesView)
import App.Products.Product                            exposing (Product)
import App.Products.Show.Actions                       exposing (Action(..))
import App.Products.UserRoles.UserRolesView as URV     exposing (UserRolesView)
import App.Products.Navigation.NavBar as NavBar        exposing (ProductViewNavBar)

type alias ProductView =
  { product         : Product
  , navBar          : ProductViewNavBar
  , featuresView    : FeaturesView
  , domainTermsView : DomainTermsView
  , userRolesView   : UserRolesView
  }

init : AppConfig -> List Product -> Product -> (ProductView, Effects Action)
init appConfig products selectedProduct =
  let (featView, featuresViewFx)       = FV.init appConfig selectedProduct
      (domainTermsView, domainTermsFx) = DTV.init selectedProduct appConfig
      (userRolesView, userRolesFx)     = URV.init selectedProduct
      productView = { product          = selectedProduct
                    , navBar           = NavBar.init products selectedProduct
                    , featuresView     = featView
                    , domainTermsView  = domainTermsView
                    , userRolesView    = userRolesView
                    }
  in ( productView
     , Effects.batch [
         Effects.map FeaturesViewAction featuresViewFx
       , Effects.map DomainTermsViewAction domainTermsFx
       , Effects.map UserRolesViewAction userRolesFx
       ]
     )
