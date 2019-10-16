module Page.Nav exposing (topNavView, bottomNavView, navInit, navUpdate, NavModel, NavMsg(..))

import Html exposing (..)
import Html.Attributes exposing (class, style, href, attribute, classList, disabled, value, type_)
import Html.Events exposing (..)

type NavMsg = Logout
            | ToggleIsActive
            | InputDidItNow String
            | ClickOutSideNav
            | CreateItem String

type alias NavModel =
  { isActive : Bool
  , didItNow : String
  }

navInit : NavModel
navInit = { isActive = False, didItNow = "" }

navUpdate : NavMsg -> NavModel -> (NavModel, Cmd NavMsg)
navUpdate msg model =
  case msg of
    ToggleIsActive -> ({model | isActive = not model.isActive}, Cmd.none)
    ClickOutSideNav -> ({model | isActive = False}, Cmd.none)
    InputDidItNow didItNow -> ({model | didItNow = didItNow}, Cmd.none)
    _ -> (model, Cmd.none)

topNavView : NavModel -> Html NavMsg
topNavView model =
  nav
    -- attrs
    [ class "navbar is-transparent is-fixed-top"
    , attribute "role" "navigation"
    , attribute "aria-label" "main navigation"
    ]
    -- elements
    [ div
        [ class "navbar-brand"]
        [ a
            [ class "navbar-item", class "title", href "/", style "margin-bottom" "0.2em" ]
            [ text "🤔 When did I? "]
        , a
            [ class "navbar-burger burger"
            , classIsActive model 
            , onClick ToggleIsActive
            ]
            [ span [][], span [][], span [][]]
        ]
    , div
        -- [ class "navbar-menu", classList [("is-active", model.isActive)]]
        [ class "navbar-menu", classIsActive model ]
        [ navbarMenuEndView ]
    ]

classIsActive : NavModel -> Attribute NavMsg
classIsActive model = classList [("is-active", model.isActive)]

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

bottomNavView : NavModel -> Html NavMsg
bottomNavView model =
  nav
    -- attrs
    [ class "navbar is-transparent is-fixed-bottom"
    , attribute "role" "navigation"
    , attribute "aria-label" "main navigation"
    ]
    -- elements
    [ div
        -- [ class "navbar-menu", classList [("is-active", model.isActive)]]
        [ class "navbar-menu is-active", style "justify-content" "stretch" ]
        [ form
            [ class "form", styleWidth100
            , onSubmit <| CreateItem model.didItNow
            ]
            [ navbarMenuStartView model
            ]
        ]
    ]

styleWidth100 = style "width" "100%"

navbarMenuStartView : NavModel -> Html NavMsg
navbarMenuStartView model =
  div
    [ class "navbar-start", styleWidth100]
    [ div
        [ class "navbar-item", styleWidth100]
        [ div
            [ class "field has-addons", styleWidth100]
            [ div
                [ class "control is-expanded"]
                [ input
                    [class "input", type_ "text", onInput InputDidItNow, value model.didItNow ]
                    []
                ]
            , div
                [ class "control"]
                [ button
                    [ class "button is-primary"
                    , disabled <| model.didItNow == ""
                    , type_ "submit"
                    ]
                    [ text "Did it Now! 🤩"]
                ]
            ]
        ]
    ]