module Page.Nav exposing (topNav)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type NavMsg = Logout

topNav : Html NavMsg
topNav =
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
            [ class "navbar-burger burger"]
            [ span [][], span [][], span [][]]
        ]
    , div
        [ class "navbar-menu"]
        [ navbarMenuEndView ]
    ]

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