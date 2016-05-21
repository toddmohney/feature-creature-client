module App.Products.DomainTerms.Index.Update exposing ( update )

import App.AppConfig                                     exposing (..)
import App.Products.DomainTerms.DomainTerm    as DT
import App.Products.DomainTerms.Forms.ViewModel as DTF
import App.Products.DomainTerms.Forms.Update  as DTF
import App.Products.DomainTerms.Index.ViewModel          exposing (DomainTermsView)
import App.Products.DomainTerms.Messages                 exposing (Msg(..))
import App.Products.DomainTerms.Requests                 exposing (getDomainTerms, removeDomainTerm)
import Data.External                                     exposing (External(..))
import Debug                                             exposing (crash, log)

update : Msg -> DomainTermsView -> AppConfig -> (DomainTermsView, Cmd Msg)
update action domainTermsView appConfig =
  case action of
    UpdateDomainTerms domainTermsResult ->
      case domainTermsResult of
        Ok domainTermList ->
          let product           = domainTermsView.product
              domainTermForm    = domainTermsView.domainTermForm
              updatedProduct    = { product | domainTerms = Loaded domainTermList }
              newDomainTermForm = Maybe.map2 DTF.setProduct domainTermForm (Just updatedProduct)
              newView = { domainTermsView |
                          product = updatedProduct
                        , domainTermForm = newDomainTermForm
                        }
          in (newView, Cmd.none)
        Err _ ->
          crash "Something went wrong!"

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

    SearchFeatures searchQuery -> (domainTermsView, Cmd.none)

    RemoveDomainTerm domainTerm ->
      (,)
      domainTermsView
      (removeDomainTerm appConfig domainTermsView.product domainTerm)

    DomainTermRemoved result ->
      -- This always results in an error, even with a 200 response
      -- because Elm cannot parse an empty response body.
      -- We can make this better, however.
      -- see: https://github.com/evancz/elm-http/issues/5
      case result of
        Ok a ->
          (,)
          domainTermsView
          (getDomainTerms appConfig domainTermsView.product)
        Err err ->
          (,)
          domainTermsView
          (getDomainTerms appConfig domainTermsView.product)

    DomainTermAdded domainTerm   -> (domainTermsView, getDomainTerms appConfig domainTermsView.product)

    DomainTermUpdated domainTerm -> (domainTermsView, getDomainTerms appConfig domainTermsView.product)

    _ ->
      case domainTermsView.domainTermForm of
        Nothing             -> (domainTermsView, Cmd.none)
        Just domainTermForm ->
          let (dtForm, dtFormFx) = DTF.update action domainTermForm appConfig
          in
            ( { domainTermsView | domainTermForm = Just dtForm }
            , dtFormFx
            )
