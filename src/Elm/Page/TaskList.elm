module Page.TaskList exposing
  ( listView
  , TaskListModel
  , taskListInit
  , TaskListMsg(..)
  , updateTaskList
  )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Html.Lazy exposing (..)

import Time exposing (..)

import Model.TaskItem exposing (..)

import Helper.Format exposing (..)

type TaskListMsg = DeleteItem Uid
                 | EditItem Uid
                 | DidItItem Uid
                 | CreateItem TaskItem
                 | UpdatedItems (List ChangeEvent)
                 | UpdatedNow Posix


type alias TaskListModel =
  { items : List TaskItemRe
  , now : Posix
  }

type alias TaskItemRe =
  { item : TaskItem
  , relative : String
  , isMenuOpened: Bool
  }

taskListInit : TaskListModel
taskListInit = { items = [], now = millisToPosix 0 }

updateTaskList : TaskListMsg -> TaskListModel -> ( TaskListModel, Cmd TaskListMsg )
updateTaskList msg model =
  case msg of
    UpdatedItems ces ->
      let newModels = mergeItems model.now ces model.items
      in ({model | items = newModels }, Cmd.none)
    UpdatedNow now ->
      ({ model
       | now = now
      --  | now = Debug.log "now" now
       , items = List.map (updateRelative model.now) model.items
       }  , Cmd.none)
    _ -> (model, Cmd.none)

updateRelative : Posix -> TaskItemRe -> TaskItemRe
updateRelative now itemRe =
  let newRelative = formatTimeRe now itemRe.item.lastUpdated
  in if itemRe.relative /= newRelative
        then { itemRe | relative = newRelative}
        else itemRe

mkTaskItemRe : Posix -> TaskItem -> TaskItemRe
mkTaskItemRe now item = { item = item
                        , relative = formatTimeRe now item.lastUpdated
                        , isMenuOpened = False
                        }

mergeItems : Posix -> List ChangeEvent -> List TaskItemRe -> List TaskItemRe
mergeItems now ces ts =
  case ces of
    [] -> ts
    (ce:: ces_) -> case ce of
      CreatedItem item -> mkTaskItemRe now item :: (mergeItems now ces_ ts)
      UpdatedItem item -> List.map (\t -> if t.item.uid == item.uid && t.item /= item then mkTaskItemRe now item else t) ts |> mergeItems now ces_
      DeletedItem item -> List.filter (\t -> t.item.uid == item.uid) ts |> mergeItems now ces_

listView : TaskListModel -> Html TaskListMsg
listView model =
  section [class "section"] <| [gridListView model.items]

gridListView : List TaskItemRe -> Html TaskListMsg
gridListView xs =
  div [ class "container"]
    [ Keyed.node "div" [ class "columns is-multiline" ] <|
      List.map (\x -> (x.item.uid, lazy columnView x)) xs
    ]
  

columnView : TaskItemRe -> Html TaskListMsg
columnView item =
  div [ class "column is-4"] [itemView item]

itemView : TaskItemRe -> Html TaskListMsg
itemView item =
  div [class ""] [itemCardView item]

itemCardView : TaskItemRe -> Html TaskListMsg
itemCardView itemRe =
  let item = itemRe.item in
  div
    -- attrs
    [ class "card"
    , id item.uid ]
    -- elements
    [ lazy itemCardViewHeader itemRe
    , lazy itemCardViewContent itemRe
    , itemCardViewFooter item
    ]

itemCardViewHeader : TaskItemRe -> Html TaskListMsg
itemCardViewHeader itemRe =
  let item = itemRe.item in
  header
    [class "card-header"]
    [ p [ class "card-header-title" ] [ text item.title ]
    , div
        [class "dropdown is-right", classList [("is-active", itemRe.isMenuOpened)]]
        [ div
            [ class "dropdown-trigger" ]
            [ div
                [class ""]
                [ a [ class "card-header-icon"]
                    [ span [ class "icon" ] [ i [class "ion ion-ios-arrow-dropdown"] []]]]
            ]
        , div
            [ class "dropdown-menu" ]
            [ div
                [ class "dropdown-content" ]
                [ a [ class "dropdown-item", attribute "disabled" ""] [ ionIcon "ios-create", text "Edit" ]
                , a [ class "dropdown-item has-text-danger" ] [ ionIcon "ios-trash", text "Delete" ]
                ]
            ]
        ]

    ]

itemCardViewContent : TaskItemRe -> Html TaskListMsg
itemCardViewContent itemRe =
  div
    [ class "card-content"]
    [ p [ class "title" ] [text itemRe.relative]
    , p [ class "subtitle"] [text <| formatTime utc itemRe.item.lastUpdated]
    ]

itemCardViewFooter : TaskItem -> Html TaskListMsg
itemCardViewFooter item =
  footer
    -- footer attrs
    [ class "card-footer"
    , style "justify-content" "center"
    ]
    -- footer elements
    [ p
        -- p attrs
        [ class "card-footer-item", style "padding" "5px 0"]
        -- p elements
        [ div
            [ class "buttons"]
            [ actionButton "ios-checkmark-circle-outline"
                [ class "is-primary"
                , onClick <| DidItItem item.uid
                ]
                "More"
            ]
        ]
    ]

actionButton : String -> List (Attribute a) -> String -> Html a
actionButton iconName attrs content =
  button
    ([ class "button is-rounded is-small" ] ++ attrs)
    [ ionIcon iconName
    , span [] [ text content]
    ]

ionIcon : String -> Html a
ionIcon iconName =
  span [ class "icon" ]
    [ i [class "icon", class <| "ion-" ++ iconName]
      []]
