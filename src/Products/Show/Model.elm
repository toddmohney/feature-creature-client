module Products.Show.Model where

import Effects                                     exposing (Effects)
import Products.DomainTerms.Index.Model as DTV     exposing (DomainTermsView)
import Products.Features.Index.Model as FV         exposing (FeaturesView)
import Products.Product                            exposing (Product)
import Products.Show.Actions                       exposing (Action(..))
import Products.UserRoles.UserRolesView as URV     exposing (UserRolesView)
import UI.App.Components.ProductViewNavBar as PVNB exposing (ProductViewNavBar)

type alias ProductView =
  { product         : Product
  , navBar          : ProductViewNavBar
  , featuresView    : FeaturesView
  , domainTermsView : DomainTermsView
  , userRolesView   : UserRolesView
  }

init : List Product -> Product -> (ProductView, Effects Action)
init products selectedProduct =
  let (featView, featuresViewFx)       = FV.init selectedProduct
      (domainTermsView, domainTermsFx) = DTV.init selectedProduct
      (userRolesView, userRolesFx)     = URV.init selectedProduct
      productView = { product          = selectedProduct
                    , navBar           = PVNB.init products selectedProduct
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
