module Page.Welcome exposing (welcome)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

welcome : Html a
welcome =
  section
    [ class "hero", class "is-fullheight", class "is-light"]
    [ div
        [ class "hero-body", style "justify-content" "center"]
        [ div [class "columns", class "is-centered", style "line-height" "1"]
            [ div
                [ class "column"
                , class "is-half"
                , style "font-size" "25vh"
                , class "has-text-centered"
                , class "has-text-right-desktop"
                ]
                [ text "🤔" ]
            , div
              [ class "column"
              , class "is-half"
              , style "font-size" "12.5vh"
              , style "font-weight" "900"
              , class "has-text-centered"
              , class "has-text-left-desktop"
              ]
              [ div [] [text "When Did I?"]
              , div [] [ a [ class "button is-primary is-large", href "/login", style "margin-top" "2em"] [ text "Login"]]
              ]
            ]
        ]
    ]

        
