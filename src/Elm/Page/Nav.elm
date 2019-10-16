module Page.Nav exposing (topNavView, bottomNavView, navInit, navUpdate, NavModel, NavMsg(..))

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

bottomNavView : NavModel -> Html NavMsg
bottomNavView model =
  nav
    -- attrs
    [ class "navbar is-transparent is-fixed-bottom"
    , attribute "role" "navigation"
    , attribute "aria-label" "main navigation"
    ]
    -- elements
    [ div
        -- [ class "navbar-menu", classList [("is-active", model.isActive)]]
        [ class "navbar-menu is-active", style "justify-content" "stretch" ]
        [ navbarMenuStartView ]
    ]
navbarMenuStartView : Html NavMsg
navbarMenuStartView =
  div
    [ class "navbar-start", style "width" "100%"]
    [ div
        [ class "navbar-item", style "width" "100%"]
        [ div
            [ class "field has-addons", style "width" "100%"]
            [ div
                [ class "control is-expanded"]
                [ input
                    [class "input", type_ "text"]
                    []
                ]
            , div
                [ class "control"]
                [ a [ class "button is-primary", onClick Logout] [ text "Did it Now! 🤩" ]
                ]
            ]
        ]
    ]