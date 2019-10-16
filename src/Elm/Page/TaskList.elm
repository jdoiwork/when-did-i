module Page.TaskList exposing
  ( listView
  , TaskListModel
  , taskListInit
  , taskListUpdate
  , TaskListMsg(..)
  )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time exposing (..)

import Model.TaskItem exposing (..)


type TaskListMsg = DeleteItem Uid
                 | EditItem Uid
                 | DidItItem Uid
                 | CreatedItem TaskItem

type alias TaskListModel =
  { items : List TaskItem
  , splitedItems : List (List TaskItem)
  }

taskListInit : TaskListModel
taskListInit = { items = dummyTasks, splitedItems = split3 dummyTasks }

dummyTasks : List TaskItem
dummyTasks = 
  [ { uid = "abc", title = "aaa 0", lastUpdated = millisToPosix 1}
  , { uid = "edf", title = "bbb 1", lastUpdated = millisToPosix 1}
  , { uid = "edf", title = "bbb 2", lastUpdated = millisToPosix 1}
  , { uid = "edf", title = "bbb 3", lastUpdated = millisToPosix 1}
  , { uid = "edf", title = "bbb 4", lastUpdated = millisToPosix 1}
  , { uid = "edf", title = "bbb 5", lastUpdated = millisToPosix 1}
  , { uid = "edf", title = "bbb 6", lastUpdated = millisToPosix 1}
  , { uid = "edf", title = "bbb 7", lastUpdated = millisToPosix 1}
  , { uid = "edf", title = "bbb 8", lastUpdated = millisToPosix 1}
  , { uid = "edf", title = "bbb 9", lastUpdated = millisToPosix 1}
  , { uid = "edf", title = "bbb 10", lastUpdated = millisToPosix 1}
  , { uid = "edf", title = "bbb 11", lastUpdated = millisToPosix 1}
  , { uid = "edf", title = "bbb 12", lastUpdated = millisToPosix 1}
  ]

taskListUpdate : TaskListModel -> TaskListMsg -> (TaskListModel, Cmd TaskListMsg)
taskListUpdate model msg =
  case msg of
    CreatedItem newItem ->
      let newItems = newItem :: model.items
      in ({ items = newItems, splitedItems = split3 newItems}, Cmd.none)
    _ -> (model, Cmd.none)

listView : TaskListModel -> Html TaskListMsg
listView model =
  section [class "section"] <| List.map gridListView model.splitedItems

gridListView : List TaskItem -> Html TaskListMsg
gridListView xs =
  div [ class "container"]
    [div [ class "columns" ] <| List.map columnView xs]
  

columnView : TaskItem -> Html TaskListMsg
columnView item =
  div [ class "column is-4"] [itemView item]

parentTileView : List TaskItem -> Html TaskListMsg
parentTileView items =
  div [class "tile is-parent is-vertical_"] <| List.map itemView items

itemView : TaskItem -> Html TaskListMsg
itemView item =
  div [class "tile is-child box_"] [itemCardView item]

itemCardView : TaskItem -> Html TaskListMsg
itemCardView item =
  div
    [ class "card", id item.uid ]
    [ header
        [class "card-header"]
        [ p [ class "card-header-title" ] [ text item.title]
        , a [ class "card-header-icon"] [ span [ class "icon"] [ i [class "ion ion-ios-arrow-dropdown"] []]]
        ]
    , div
        [ class "card-content"]
        [ text "2019/10/16 12:34:56"]
    , footer
        [ class "card-footer"
        , style "justify-content" "center"
        
        ]
        -- [ a [ class "card-footer-item", onClick <| Delete item.uid ] [ text "delete"]
        -- , p [ class "card-footer-item" ]
        --     [a [class "button is-fullwidth"] [ text "delete"]]
        -- , a [ class "card-footer-item", onClick <| Delete item.uid ] [ text "Edit"]
        -- , a [ class "card-footer-item", onClick <| Delete item.uid ] [ text "Done Again!"]
        -- ]
        [ p
            [ class "card-footer-item", style "padding" "5px 0"]
            [ div
                [ class "buttons"]
                -- [ actionButton "ios-trash" [ class "is-danger"] ""
                -- , actionButton "ios-create" [ class "is-info"] ""
                -- , actionButton "ios-checkmark-circle-outline" [ class "is-primary"] "Done"
                -- ]
                [ actionButton "ios-checkmark-circle-outline" [ class "is-primary"] "More"
                ]

            ]
        ]
    ]

actionButton : String -> List (Attribute a) -> String -> Html a
actionButton iconName attrs content =
  button
    ([ class "button is-rounded is-small" ] ++ attrs)
    [ span
        [ class "icon is-large" ]
        [ i [class "icon", class <| "ion-" ++ iconName] []]
    , span [] [ text content]
    ]
type alias ItemTuple a = (List a, List a, List a)

-- split3 : List a -> ItemTuple a
-- split3 xs =
--   let len = 1 + (List.length xs) // 3
--       a = List.take len xs
--       b = List.drop len xs |> List.take len
--       c = List.drop (len * 2) xs
--   in (a, b, c)

split3 : List a -> List (List a)
split3 xs =
  let go items a =
        case items of
          [] -> List.reverse a
          _ -> go (List.drop 3 items) (List.take 3 items :: a)
  in go xs []
split3v : List a -> ItemTuple a
split3v xs =
  let seed = (Left, ([], [], []))
      dist = \item (pos, items) -> (nextPos pos, distribute item pos items)
      (_, (a, b, c)) = List.foldl dist seed xs
  in (List.reverse a, List.reverse b, List.reverse c)

type Pos = Left | Center | Right

nextPos : Pos -> Pos
nextPos pos =
  case pos of
    Left -> Center
    Center -> Right
    Right -> Left

distribute : a -> Pos -> ItemTuple a -> ItemTuple a
distribute item pos (a, b, c) =
  case pos of
    Left -> (item :: a, b, c)
    Center -> (a, item :: b, c)
    Right -> (a, b, item :: c)
