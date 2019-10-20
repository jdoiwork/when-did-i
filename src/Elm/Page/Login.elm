module Page.Login exposing (login, AuthProvider, Msg(..), stringFromProvider)


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Attributes as A
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
          [ button [ buttonClass, onClick <| LoginWith Google] <|
              iconWithText "logo-google" "Google"
          , button [ buttonClass, disabled True] <|
              iconWithText "logo-facebook" "Facebook"
          , button [ buttonClass, disabled True] <|
              iconWithText "logo-twitter" "Twitter"
          , button [ buttonClass, onClick <| LoginWith Github] <|
              iconWithText "logo-github" "Github"

          -- <i class="material-icons">face</i>
          -- <i class="ion-logo-facebook"></i>
          ]
    -- , div [class "conteiner"] [progress [ class "progress is-primary", A.max "100"] [text "50%"]]
    -- [class "is-loading"]
    ]]

type alias IconName = String

iconWithText : IconName -> String -> List (Html a)
iconWithText iconName t =
  [ ionIcon iconName
  , span [] [text t]
  ]

ionIcon : String -> Html a
ionIcon ionName = span [ class "icon"] [i [ class <| "ion-" ++ ionName] []]

  
buttonClass = class "button is-large is-fullwidth"

stringFromProvider : AuthProvider -> String
stringFromProvider provider =
  case provider of
    Google -> "google"
    Facebook -> "facebook"
    Twitter -> "twitter"
    Github -> "github"
