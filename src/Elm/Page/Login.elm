module Page.Login exposing (login)


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

login : Html a
login =
  section
    [ class "section"]
    [ h1 [ class "title"] [ text "Login with"]
    , div
        [ class "columns"]
        [ button [ buttonClass] [text "Google"]
        , button [ buttonClass, disabled True] [text "Facebook"]
        , button [ buttonClass, disabled True] [text "Twitter"]
        , button [ buttonClass, disabled True] [text "Github"]


        ]

    ]
  
buttonClass = class "button is-large is-fullwidth"
