module Products.CreateProductForm where

import Debug                 exposing (crash)
import Effects               exposing (Effects)
import Html                  exposing (Html)
import Html.Events           exposing (onClick)
import Http as Http          exposing (..)
import Products.Product as P exposing (Product)
import Task as Task          exposing (..)
import UI.App.Primitives.Forms     as UI exposing (..)
import Utils.Http

type alias CreateProductForm =
  { newProduct   : Product
  , nameField    : InputField Action
  , repoUrlField : InputField Action
  }

type Action = SubmitForm
            | SetName String
            | SetRepositoryUrl String
            | AddNewProduct (Result Error Product)

init : CreateProductForm
init = { newProduct   = P.newProduct
       , nameField    = defaultNameField
       , repoUrlField = defaultRepoUrlField
       }

defaultNameField : InputField Action
defaultNameField =
  { inputName = "name"
  , labelContent = (Html.text "Name")
  , inputParser = SetName
  , validationErrors = []
  }

defaultRepoUrlField : InputField Action
defaultRepoUrlField =
  { inputName = "repoUrl"
  , labelContent = (Html.text "Git Repository Url")
  , inputParser = SetRepositoryUrl
  , validationErrors = []
  }

update : Action -> CreateProductForm -> (CreateProductForm, Effects Action)
update action form =
  case action of
    SetName name ->
      let product = form.newProduct
          updatedProduct = { product | name = name }
      in ( { form | newProduct = updatedProduct }
         , Effects.none
         )

    SetRepositoryUrl url ->
      let product = form.newProduct
          updatedProduct = { product | repoUrl = url }
      in ( { form | newProduct = updatedProduct }
         , Effects.none
         )

    SubmitForm ->
      let newProductForm = validateForm form
      in
         case hasErrors newProductForm of
           True ->
             ( newProductForm
             , Effects.none
             )
           False ->
             ( newProductForm
             , createProduct newProductForm.newProduct
             )

    AddNewProduct createProductResult ->
      case createProductResult of
        Ok product ->
          ( { form | newProduct = product }
          , Effects.none
          )
        Err _ -> crash "Failed to create product"

validateForm : CreateProductForm -> CreateProductForm
validateForm createProductForm =
  let product         = createProductForm.newProduct
      nameField       = createProductForm.nameField
      repoUrlField    = createProductForm.repoUrlField
      newNameField    = { nameField | validationErrors    = validateName product.name }
      newRepoUrlField = { repoUrlField | validationErrors = validateRepoUrl product.repoUrl }
  in
     { createProductForm | nameField = newNameField
                         , repoUrlField = newRepoUrlField
     }

validateName : String -> (List String)
validateName = requiredStringFieldValidation

validateRepoUrl : String -> (List String)
validateRepoUrl = requiredStringFieldValidation

hasErrors : CreateProductForm -> Bool
hasErrors = not << isSubmittable

isSubmittable : CreateProductForm -> Bool
isSubmittable createProductForm =
  let nameField    = createProductForm.nameField
      repoUrlField = createProductForm.repoUrlField
  in
     (List.isEmpty nameField.validationErrors)
     && (List.isEmpty repoUrlField.validationErrors)

view : Signal.Address Action -> CreateProductForm -> Html
view address createProductForm =
  Html.div
    []
    [ UI.input' address createProductForm.nameField
    , UI.textarea' address createProductForm.repoUrlField
    , UI.submitButton (onClick address SubmitForm)
    ]

createProduct : Product -> Effects Action
createProduct newProduct =
  let request = Utils.Http.jsonPostRequest createProductUrl (P.encodeProduct newProduct)
  in Http.send Http.defaultSettings request
     |> Http.fromJson P.parseProduct
     |> Task.toResult
     |> Task.map AddNewProduct
     |> Effects.task

createProductUrl : String
createProductUrl = "http://localhost:8081/products"
