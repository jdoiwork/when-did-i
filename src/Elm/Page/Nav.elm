module Page.Nav exposing (topNavView, navInit, navUpdate, NavModel, NavMsg(..))

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type NavMsg = Logout
            | ToggleIsActive
            | ClickOutSideNav

type alias NavModel =
  { isActive : Bool
  }

navInit : NavModel
navInit = { isActive = False }

navUpdate : NavMsg -> NavModel -> (NavModel, Cmd NavMsg)
navUpdate msg model =
  case msg of
    ToggleIsActive -> ({model | isActive = not model.isActive}, Cmd.none)
    ClickOutSideNav -> ({model | isActive = False}, Cmd.none)
    _ -> (model, Cmd.none)

topNavView : NavModel -> Html NavMsg
topNavView model =
  nav
    -- attrs
    [ class "navbar is-transparent is-fixed-top"
    , attribute "role" "navigation"
    , attribute "aria-label" "main navigation"
    ]
    -- elements
    [ div
        [ class "navbar-brand" ]
        [ a
            [ class "navbar-item", class "title", href "/" ]
            [ text "🤔 When did I? "]
        , a
            [ class "navbar-burger burger"
            , classIsActive model 
            , onClick ToggleIsActive
            ]
            [ span [][], span [][], span [][]]
        ]
    , div
        -- [ class "navbar-menu", classList [("is-active", model.isActive)]]
        [ class "navbar-menu", classIsActive model ]
        [ navbarMenuEndView ]
    ]

classIsActive : NavModel -> Attribute NavMsg
classIsActive model = classList [("is-active", model.isActive)]

navbarMenuEndView : Html NavMsg
navbarMenuEndView =
  div
    [ class "navbar-end"]
    [ div
        [ class "navbar-item"]
        [ div
            [ class "buttons"]
            [ a [ class "button", onClick Logout] [ text "Logout"]]
        ]


    ]