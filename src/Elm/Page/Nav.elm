module Page.Nav exposing
    ( topNavView, topNavViewWithoutFixed, bottomNavView
    , navInit, navUpdate, NavModel, NavMsg(..))

import Html exposing (..)
import Html.Attributes exposing ( class, style, href, attribute, classList
                                , disabled, value, type_, name, id, for)
import Html.Attributes.Aria exposing ( ariaLabel, ariaLabelledby)
import Html.Lazy exposing (..)

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
    CreateItem _ -> ({ model | didItNow = "" }, Cmd.none)
    _ -> (model, Cmd.none)

topNavView : NavModel -> Html NavMsg
topNavView = topNavViewCore True

topNavViewWithoutFixed : NavModel -> Html NavMsg
topNavViewWithoutFixed = topNavViewCore False

topNavViewCore : Bool -> NavModel -> Html NavMsg
topNavViewCore isFixed model =
  nav
    -- attrs
    [ class "navbar is-transparent"
    , classList [("is-fixed-top", isFixed)]
    , attribute "role" "navigation"
    , attribute "aria-label" "main navigation"
    ]
    -- elements
    [ div
        [ class "navbar-brand"]
        [ a
            [ class "navbar-item", class "title", href "/", style "margin-bottom" "0.2em" ]
            [ text "🤔 When Did I? "]
        , a
            [ class "navbar-burger burger"
            , classIsActive model 
            , onClick ToggleIsActive
            ]
            [ span [][], span [][], span [][]]
        ]
    , div
        -- [ class "navbar-menu", classList [("is-active", model.isActive)]]
        [ class "navbar-menu", classIsActive model, classList [("is-hidden", not isFixed)] ]
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
    [ class "navbar is-fixed-bottom is-primary_"
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
            [ lazy navbarMenuStartView model
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
                [ label
                    [ for "new-title", class "is-hidden", ariaLabel "new title", id "new-title-label"]
                    [ text "new title" ]
                , lazy titleInput model.didItNow
                ]
            , div
                [ class "control"]
                [ button
                    [ class "button is-primary is-outlined_ is-inverted_"
                    , disabled <| model.didItNow == ""
                    , type_ "submit"
                    ]
                    [ text "Did it Now! 🤩"]
                ]
            ]
        ]
    ]

titleInput : String -> Html NavMsg
titleInput didItNow =
    input
        -- attrs
        [ class "input"
        , type_ "text"
        , onInput InputDidItNow
        , value didItNow
        , name "title"
        , id "new-title"
        , ariaLabelledby "new-title-label"
        ]
        -- elements
        [

        ]