module Page.Nav exposing (topNav)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


topNav : Html a
topNav =
  div []
    [ topNavX
    --, topNavY
    ]

topNavX : Html a
topNavX =
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
        ]

    ]

topNavY : Html a
topNavY =
  nav
    -- attrs
    [ class "navbar is-transparent "
    , attribute "role" "navigation"
    , attribute "aria-label" "main navigation"
    , style "visibility" "hidden"
    ]
    -- elements
    [ div
        [ class "navbar-brand" ]
        [ 
        ]

    ]