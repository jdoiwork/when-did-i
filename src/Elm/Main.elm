port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (..)
import Json.Encode as E
import Json.Decode as D
import Url

import Page.Nav exposing (..)
import Page.Welcome exposing (..)
import Page.Login
import Page.TaskList exposing (..)

import Model.TaskItem exposing (..)

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
  , topNavState : NavModel
  , taskListState : TaskListModel
  }
  
type LoginStatus = Checking
                 | LoggedOut
                 | LoggedIn


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
  ( Model key url Checking navInit taskListInit, Cmd.none )

type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | LoginStatusChanged String
  | RequestLogin Page.Login.AuthProvider
  | RequestTopNavMsg NavMsg
  | PostNewItem String
  | CreatedNewItem (Result D.Error TaskItem)
  | ClickBody
  | Ignore


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    LinkClicked urlRequest ->
      case urlRequest of
        Browser.Internal url ->
          ( model, Nav.pushUrl model.key (Url.toString url) )

        Browser.External "" -> -- Ignore empty link
          ( model, Cmd.none )
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
          cmd = if key == "logout" && model.url.path == "/login"
                  then Cmd.none
                  else Nav.pushUrl model.key "/"
      in ( { model | login = login }, cmd )

    RequestLogin provider ->
      ( model, loginWith <| E.string "google")
      
    RequestTopNavMsg navMsg ->
      case navMsg of
        Logout -> ({model | topNavState = navInit }, logout ())
        _ ->
          let (navModel, _) = navUpdate navMsg model.topNavState
          in ({model | topNavState = navModel}, Cmd.none)
    PostNewItem didItNow ->
      (model, postNewItem model.topNavState.didItNow)
    CreatedNewItem resultNewItem ->
      case resultNewItem of
        Err error -> (model, Cmd.none)
        Ok newItem ->
          let (taskListState, _) = taskListUpdate model.taskListState <| CreatedItem newItem
          in ({ model
              | taskListState = taskListState
              , topNavState = navInit }
              , Cmd.none)

    ClickBody ->
      let (navModel, _) = navUpdate ClickOutSideNav model.topNavState
      in ({model | topNavState = navModel}, Cmd.none)
    Ignore -> (model, Cmd.none)
-- SUBSCRIPTIONS

port loginStatusChanged : (String -> msg) -> Sub msg
port loginWith : E.Value -> Cmd msg
port logout : () -> Cmd msg
port postNewItem : String -> Cmd msg
port createdNewItem : (D.Value -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ loginStatusChanged LoginStatusChanged
    , createdNewItem convertNewItemWithValue
    ]

convertNewItemWithValue : D.Value -> Msg
convertNewItemWithValue value = value |> decodeTaskItem |> CreatedNewItem

-- VIEWS

view : Model -> Browser.Document Msg
view model =
  { title = "When did I? 🤔"
  , body = [
      div [class "bg", classList [("login", isFixedNavbar model)]] <| selectPage model
    ]
  }

isFixedNavbar : Model -> Bool
isFixedNavbar model =
  model.url.path /= "/login" &&
  model.login == LoggedIn

selectPage model = model |>
  case model.url.path of
    "/login" -> showLogin
    _        -> showIndex

showLogin : Model -> List (Html Msg)
showLogin model =
  [ mapNavView model topNavViewWithoutFixed
  , Html.map (\(Page.Login.LoginWith p) -> RequestLogin p) Page.Login.login

  ]

showIndex : Model -> List (Html Msg)
showIndex model =
  case model.login of
    LoggedOut -> [loggedOutView model]
    _         ->
      [ mapNavView model topNavView
      , main_ []
          [ div [onClick ClickBody]
              [ lazy loginStatus model ]
          ]
      , mapNavView model bottomNavView
      ]

mapNavView : Model -> (NavModel -> Html NavMsg) -> Html Msg
mapNavView model navView =
  Html.map convertNavMsg <| lazy navView model.topNavState

convertNavMsg : NavMsg -> Msg
convertNavMsg nav =
  case nav of
    CreateItem didItNow -> PostNewItem didItNow
    _ -> RequestTopNavMsg nav

loginStatus : Model -> Html Msg
loginStatus model =
  case model.login of
    Checking  -> section [ class "section"] [text "Checking Login Status..."]
    LoggedOut -> loggedOutView model
    LoggedIn  -> loggedInView model
    
loggedOutView : Model -> Html Msg
loggedOutView model =
  main_ []
    [ welcome
    ]

loggedInView : Model -> Html Msg
loggedInView model =
  div []
    [ Html.map (\_ -> Ignore) <| listView model.taskListState
    --, button [ class "button", onClick <| RequestLogout ] [text "Logout"]
    ]
