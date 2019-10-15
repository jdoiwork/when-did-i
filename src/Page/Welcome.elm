module Page.Welcome exposing (welcome)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

welcome : Html a
welcome =
  section
    [ class "hero", class "is-fullheight", class "is-light"]
    [ div
        [ class "hero-body"]
        [ div [class "columns"]
            [ div [ class "column", style "font-size" "2000%", class "has-text-centered", class "has-text-right-desktop"] [ text "🤔" ]
            , div [ class "column", style "font-size" "1000%", style "font-weight" "900"] [ text "When Did I?" ]

            ]

        ]]
