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
import Time exposing (Posix, Zone)
import Task
import Tuple exposing (first)

import Page.Nav exposing (..)
import Page.Welcome exposing (..)
import Page.Login
import Page.LoggingIn exposing (..)
import Page.TaskList exposing (..)

import Model.TaskItem exposing (..)

import Helper.Format exposing (..)
import Helper.Cmd exposing (..)

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
  ( Model key url Checking navInit taskListInit
  , Cmd.batch
    [ Task.perform Tick Time.now
    , Task.perform ZoneChanged Time.here
    ]
  )

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
  | ZoneChanged Zone
  | NotifyTaskItemIsUpdated Uid
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
      in ({ model
          | login = login
          , topNavState = navInit
          , taskListState = taskListInitWithOutTime model.taskListState
          }, cmd )

    RequestLogin provider ->
      ( model
      , Cmd.batch
          [ Nav.pushUrl model.key "/logging-in"
          , loginWith <| E.string <| Page.Login.stringFromProvider provider
          ]
      )
      
    RequestTopNavMsg navMsg ->
      case navMsg of
        Logout ->
          { model
          | topNavState = navInit
          } |> withCmd (logout ())
        Page.Nav.CreateItem didItNow ->
          { model
          | topNavState = navUpdate navMsg model.topNavState |> dropCmd
          } |> withCmd (postNewItem didItNow)
        _ ->
          { model
          | topNavState = navUpdate navMsg model.topNavState |> dropCmd
          } |> withCmdNone

    RequestByList taskListMsg ->
      let newCmd = case taskListMsg of
                    DidItItem uid -> patchItemDidIt uid
                    ApplyEditForm taskItem -> patchItem <| encodeTaskItem taskItem
                    DeleteItem uid -> deleteItem uid
                    _ ->  Cmd.none
      in
      { model
      | taskListState = updateTaskList taskListMsg model.taskListState |> dropCmd
      } |> withCmd newCmd

    UpdatedItems result ->
      case result of
        Ok items ->
          { model
          | taskListState = updateTaskList (Page.TaskList.UpdatedItems items) model.taskListState |> dropCmd
          } |> withCmdNone
        _ -> (model, Cmd.none)

    Tick now -> 
      { model
      | taskListState = updateTaskList (UpdatedNow now) model.taskListState |> dropCmd
      } |> withCmdNone

    ZoneChanged zone -> -- let _ = Debug.log "ZoneChanged" zone in
      { model
      | taskListState = updateTaskList (UpdatedZone zone) model.taskListState |> dropCmd
      } |> withCmdNone
      

    ClickBody ->
      { model
      | topNavState = navUpdate ClickOutSideNav model.topNavState |> dropCmd
      , taskListState = updateTaskList CloseAllMenu model.taskListState |> dropCmd
      } |> withCmdNone

    NotifyTaskItemIsUpdated uid ->
      { model
      | taskListState = updateTaskList (TaskItemIsUpdated uid) model.taskListState |> dropCmd
      } |> withCmdNone

    Ignore -> (model, Cmd.none)

-- SUBSCRIPTIONS
-- ports

port loginStatusChanged : (String -> msg) -> Sub msg
port loginWith : E.Value -> Cmd msg
port logout : () -> Cmd msg
port postNewItem : String -> Cmd msg
port patchItemDidIt : String -> Cmd msg
port patchItem : E.Value -> Cmd msg
port deleteItem : String -> Cmd msg

port createdNewItem : (D.Value -> msg) -> Sub msg
port updatedItems : (D.Value -> msg) -> Sub msg
port notifyTaskItemIsUpdated : (String -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ loginStatusChanged LoginStatusChanged
    , updatedItems convertUpdatedItems
    , notifyTaskItemIsUpdated NotifyTaskItemIsUpdated
    , everyNSec 3
    ]

everyNSec : Float -> Sub Msg
everyNSec n = Time.every (n * 1000) Tick

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
    "/logging-in" -> showLoggingIn
    _        -> showIndex

showLogin : Model -> List (Html Msg)
showLogin model =
  [ mapNavView model topNavViewWithoutFixed
  , Html.map (\(Page.Login.LoginWith p) -> RequestLogin p) Page.Login.login

  ]

showLoggingIn : Model -> List (Html Msg)
showLoggingIn model = 
  [ mapNavView model topNavViewWithoutFixed
  , viewLoggingIn
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
