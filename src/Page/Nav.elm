module Page.Nav exposing (topNav)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


topNav : Html a
topNav =
  nav
    -- attrs
    [ class "navbar"
    , attribute "role" "navigation"
    , attribute "aria-label" "main navigation"
    ]
    -- elements
    [ div
        [ class "navbar-brand" ]
        [ a
            [ class "navbar-item", class "title", href "/" ]
            [ text "🤔 When did I? "]
        ]

    ]
