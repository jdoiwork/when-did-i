module Page.LoggingIn exposing (viewLoggingIn)


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Attributes as A
import Html.Events exposing (..)

viewLoggingIn : Html a
viewLoggingIn =
  main_ []
    [ h1 [] [ text "Logging in..." ]
    , p [] [ text "Waiting for authentication result." ]
    , p []
        [ a [ class "button is-primary"] [ text "Retry" ] ]
    ]
