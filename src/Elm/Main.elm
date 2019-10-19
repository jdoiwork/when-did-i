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
import Time exposing (Posix)
import Task
import Tuple exposing (first)

import Page.Nav exposing (..)
import Page.Welcome exposing (..)
import Page.Login
import Page.TaskList exposing (..)

import Model.TaskItem exposing (..)

import Helper.Format exposing (..)

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
  ( Model key url Checking navInit taskListInit, Task.perform Tick Time.now )

type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | LoginStatusChanged String
  | RequestLogin Page.Login.AuthProvider
  | RequestTopNavMsg NavMsg
  | UpdatedItems (Result D.Error (List ChangeEvent))
  | RequestByList TaskListMsg
  | ClickBody
  | Tick Posix
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
        Page.Nav.CreateItem didItNow ->
          let (navModel, _) = navUpdate navMsg model.topNavState
          in ({model | topNavState = navModel},
            postNewItem didItNow
            )
        _ ->
          let (navModel, _) = navUpdate navMsg model.topNavState
          in ({model | topNavState = navModel}, Cmd.none)

    RequestByList taskListMsg ->
      case taskListMsg of
        DidItItem uid -> (model, patchItemDidIt uid)
        _ -> ({ model
              | taskListState = updateTaskList taskListMsg model.taskListState |> first
              }
              , Cmd.none)

    UpdatedItems result ->
      case result of
        Ok items ->
          let (newTaskList, _) = updateTaskList (Page.TaskList.UpdatedItems items) model.taskListState 
          in ({ model | taskListState = newTaskList }, Cmd.none)
        _ -> (model, Cmd.none)

    Tick now -> 
      ( { model
        | taskListState = updateTaskList (UpdatedNow now) model.taskListState |> first
        }
      , Cmd.none)

    ClickBody ->
      ( { model
        | topNavState = navUpdate ClickOutSideNav model.topNavState |> first
        , taskListState = updateTaskList CloseAllMenu model.taskListState |> first
        }, Cmd.none)
    Ignore -> (model, Cmd.none)

-- SUBSCRIPTIONS

port loginStatusChanged : (String -> msg) -> Sub msg
port loginWith : E.Value -> Cmd msg
port logout : () -> Cmd msg
port postNewItem : String -> Cmd msg
port patchItemDidIt : String -> Cmd msg

port createdNewItem : (D.Value -> msg) -> Sub msg
port updatedItems : (D.Value -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ loginStatusChanged LoginStatusChanged
    , updatedItems convertUpdatedItems
    , Time.every 5000 Tick -- every 5 sec
    ]

-- convertNewItemWithValue : D.Value -> Msg
-- convertNewItemWithValue value = value |> decodeTaskItem |> CreatedNewItem

convertUpdatedItems : D.Value -> Msg
convertUpdatedItems value = value |> decodeUpdatedItems |> UpdatedItems

-- VIEWS

view : Model -> Browser.Document Msg
view model =
  { title = "When Did I? 🤔"
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
  Html.map RequestTopNavMsg <| lazy navView model.topNavState

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
    [ Html.map RequestByList <| listView model.taskListState
    ]
