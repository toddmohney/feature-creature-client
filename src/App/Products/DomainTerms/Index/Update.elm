module App.Products.DomainTerms.Index.Update exposing ( update )

import App.AppConfig                                     exposing (..)
import App.Products.DomainTerms.DomainTerm    as DT
import App.Products.DomainTerms.Forms.ViewModel as DTF
import App.Products.DomainTerms.Forms.Update  as DTF
import App.Products.DomainTerms.Index.ViewModel          exposing (DomainTermsView)
import App.Products.DomainTerms.Messages                 exposing (Msg(..))
import App.Products.DomainTerms.Requests                 exposing (getDomainTerms, removeDomainTerm)
import App.Products.Product                              exposing (Product)
import Data.External                                     exposing (External(..))
import Debug                                             exposing (crash)

update : Msg -> DomainTermsView -> AppConfig -> (DomainTermsView, Cmd Msg)
update action domainTermsView appConfig =
  case action of
    FetchDomainTermsSucceeded domainTerms ->
      let product           = domainTermsView.product
          domainTermForm    = domainTermsView.domainTermForm
          updatedProduct    = { product | domainTerms = Loaded domainTerms }
          newDomainTermForm = Maybe.map2 DTF.setProduct domainTermForm (Just updatedProduct)
          newView = { domainTermsView |
                      product = updatedProduct
                    , domainTermForm = newDomainTermForm
                    }
      in (newView, Cmd.none)

    DeleteDomainTermSucceeded _ -> (domainTermsView, fetchDomainTerms domainTermsView.product appConfig)

    CreateDomainTermSucceeded _ -> (domainTermsView, fetchDomainTerms domainTermsView.product appConfig)

    UpdateDomainTermSucceeded _ -> (domainTermsView, fetchDomainTerms domainTermsView.product appConfig)

    FetchDomainTermsFailed _ -> crash "Unable to fetch domain terms"

    DeleteDomainTermFailed _ -> crash "Unable to delete domain term"

    RemoveDomainTerm domainTerm -> (domainTermsView, removeDomainTerm appConfig domainTermsView.product domainTerm)

    DomainTermRemoved _ -> (domainTermsView, fetchDomainTerms domainTermsView.product appConfig)

    ShowCreateDomainTermForm ->
      let product = domainTermsView.product
          newForm = DTF.init product DT.init DTF.Create
      in
        ({ domainTermsView | domainTermForm = Just newForm }, Cmd.none)

    ShowEditDomainTermForm domainTerm ->
      let product = domainTermsView.product
          newForm = DTF.init product domainTerm DTF.Edit
      in
        ({ domainTermsView | domainTermForm = Just newForm }, Cmd.none)

    HideDomainTermForm ->
      ({ domainTermsView | domainTermForm = Nothing }, Cmd.none)

    -- TODO: Separate and wrap up Domain Term form actions
    _ ->
      case domainTermsView.domainTermForm of
        Nothing             -> (domainTermsView, Cmd.none)
        Just domainTermForm ->
          let (dtForm, dtFormFx) = DTF.update action domainTermForm appConfig
          in
            ( { domainTermsView | domainTermForm = Just dtForm }
            , dtFormFx
            )

fetchDomainTerms : Product -> AppConfig -> Cmd Msg
fetchDomainTerms product config = getDomainTerms config product
