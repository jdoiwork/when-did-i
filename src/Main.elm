port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as E
import Url

import Page.Nav exposing (..)

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
  , login : LoginStatus
  }
  
type LoginStatus = Checking
                 | LoggedOut
                 | LoggedIn

type AuthProvider = Google
                  | Twitter
                  | Facebook
                  | Github

init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
  ( Model key url Checking, Cmd.none )

type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | LoginStatusChanged String
  | LoginWith AuthProvider
  | Logout


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
                    "login" -> LoggedIn
                    "logout" -> LoggedOut
                    _ -> Checking
      in ( { model | login = login }, Cmd.none )

    LoginWith provider ->
      ( model, loginWith <| E.string "google")
      
    Logout -> (model, logout ())
-- SUBSCRIPTIONS

port refreshTimer : (String -> msg) -> Sub msg

port loginStatusChanged : (String -> msg) -> Sub msg
port loginWith : E.Value -> Cmd msg
port logout : () -> Cmd msg

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ loginStatusChanged LoginStatusChanged
    ]

-- VIEWS

view : Model -> Browser.Document Msg
view model =
  { title = "When did I? 🤔"
  , body =
    [ topNav
    , p [] [ loginStatus model ]
    ]
  }
  
loginStatus : Model -> Html Msg
loginStatus model =
  case model.login of
    Checking  -> text "Checking..."
    LoggedOut -> loggedOutView model
    LoggedIn  -> loggedInView model
    
loggedOutView : Model -> Html Msg
loggedOutView model =
  div []
    [ h1 [] [ text "Login"]
    , button [ class "button", onClick <| LoginWith Google ] [text "Google Login"]
    ]

loggedInView : Model -> Html Msg
loggedInView model =
  div []
    [ h1 [] [ text "Hello 😀"]
    , button [ class "button", onClick <| Logout ] [text "Logout"]
    ]
