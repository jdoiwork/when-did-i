port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url

main : Program () Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlChange = UrlChanged
    , onUrlRequest = LinkClicked
    }
    


-- MODEL


type alias Model =
  { key : Nav.Key
  , url : Url.Url
  , login : Login
  }
  
type Login = Checking
           | Logout
           | Login


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
  ( Model key url Checking, Cmd.none )

type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | LoginStatusChanged String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    LinkClicked urlRequest ->
      case urlRequest of
        Browser.Internal url ->
          ( model, Nav.pushUrl model.key (Url.toString url) )

        Browser.External href ->
          ( model, Nav.load href )

    UrlChanged url ->
      ( { model | url = url }
      , Cmd.none
      )
      
    LoginStatusChanged key ->
      let login = case key of
                    "login" -> Login
                    "logout" -> Logout
                    _ -> Checking
      in ( { model | login = login }, Cmd.none )

-- SUBSCRIPTIONS

port refreshTimer : (String -> msg) -> Sub msg

port loginStatusChanged : (String -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ loginStatusChanged LoginStatusChanged
    ]



view : Model -> Browser.Document Msg
view model =
  { title = "When did I?"
  , body =
    [ h1 [] [text "Elm hello"]
    , p [] [ loginStatus model ]
    ]
  }
  
loginStatus : Model -> Html Msg
loginStatus model =
  case model.login of
    Checking -> text "Checking"
    Logout   -> text "Logout"
    Login    -> text "Login"
    