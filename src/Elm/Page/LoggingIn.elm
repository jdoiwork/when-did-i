module Page.LoggingIn exposing (viewLoggingIn)


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Attributes as A
import Html.Events exposing (..)

viewLoggingIn : Html a
viewLoggingIn =
  main_ [ class "hero is-info is-bold"]
    [ div [class "hero-body"]
      [ div [ class "container"] 
          viewContainer]]

viewContainer : List (Html a)
viewContainer =
    [ h1 [ class "title"] [ text "Logging in..." ]
    , p [ class "subtitle"] [ text "Waiting for authentication result." ]
    , p [ class "buttons are-large"]
        [ a [ class "button is-loading is-light"]
            [ text "login" ]
        , a [ class "button is-primary", href "/login"]
            [ text "Retry 😘" ]
        ]
    ]
