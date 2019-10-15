module Page.Login exposing (login, AuthProvider, Msg(..))


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type AuthProvider = Google
                  | Twitter
                  | Facebook
                  | Github

type Msg
  = LoginWith AuthProvider

login : Html Msg
login =
  section
    [ class "section"]
    [ div [class "container"]
      [ h1 [ class "title"] [ text "Login with"]
      , div
          [ class "columns"]
          [ button [ buttonClass, onClick <| LoginWith Google] [text "Google"]
          , button [ buttonClass, disabled True] [text "Facebook"]
          , button [ buttonClass, disabled True] [text "Twitter"]
          , button [ buttonClass, disabled True] [text "Github"]


          ]
    ]]


    
  
buttonClass = class "button is-large is-fullwidth"
