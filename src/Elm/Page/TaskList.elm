module Page.TaskList exposing
  ( listView
  , TaskListModel
  , taskListInit
  , taskListUpdate
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


type TaskListMsg = DeleteItem Uid
                 | EditItem Uid
                 | DidItItem Uid
                 | CreateItem TaskItem
                 | UpdatedItems (List ChangeEvent)

type ChangeEvent = CreatedItem TaskItem
                 | UpdatedItem TaskItem
                 | DeletedItem TaskItem

type alias TaskListModel =
  { items : List TaskItem
  }

taskListInit : TaskListModel
taskListInit = { items = dummyTasks }

dummyTasks : List TaskItem
dummyTasks = 
  [ { uid = "abc-0", title = "aaa 0", lastUpdated = millisToPosix 1}
  , { uid = "edf-1", title = "bbb 1", lastUpdated = millisToPosix 1}
  , { uid = "edf-2", title = "bbb 2", lastUpdated = millisToPosix 1}
  , { uid = "edf-3", title = "bbb 3", lastUpdated = millisToPosix 1}
  , { uid = "edf-4", title = "bbb 4", lastUpdated = millisToPosix 1}
  , { uid = "edf-5", title = "bbb 5", lastUpdated = millisToPosix 1}
  , { uid = "edf-6", title = "bbb 6", lastUpdated = millisToPosix 1}
  , { uid = "edf-7", title = "bbb 7", lastUpdated = millisToPosix 1}
  , { uid = "edf-8", title = "bbb 8", lastUpdated = millisToPosix 1}
  , { uid = "edf-9", title = "bbb 9", lastUpdated = millisToPosix 1}
  , { uid = "edf-10", title = "bbb 10", lastUpdated = millisToPosix 1}
  , { uid = "edf-11", title = "bbb 11", lastUpdated = millisToPosix 1}
  , { uid = "edf-12", title = "bbb 12", lastUpdated = millisToPosix 1}
  ]

updateTaskList : TaskListMsg -> TaskListModel -> ( TaskListModel, Cmd TaskListMsg )
updateTaskList msg model =
  case msg of
    UpdatedItems ces -> ({model | items = mergeItems ces model.items}, Cmd.none)
    _ -> (model, Cmd.none)


mergeItems : List ChangeEvent -> List TaskItem -> List TaskItem
mergeItems ces ts =
  case ces of
    [] -> ts
    (ce:: ces_) -> case ce of
      CreatedItem item -> item :: (mergeItems ces_ ts)
      UpdatedItem item -> List.map (\t -> if t.uid == item.uid && t /= item then item else t) ts |> mergeItems ces_
      DeletedItem item -> List.filter (\t -> t.uid == item.uid) ts |> mergeItems ces_

taskListUpdate : TaskListModel -> TaskListMsg -> (TaskListModel, Cmd TaskListMsg)
taskListUpdate model msg =
  case msg of
    CreateItem newItem ->
      let newItems = newItem :: model.items
      in ({ items = newItems }, Cmd.none)
    _ -> (model, Cmd.none)

listView : TaskListModel -> Html TaskListMsg
listView model =
  section [class "section"] <| [gridListView model.items]

gridListView : List TaskItem -> Html TaskListMsg
gridListView xs =
  div [ class "container"]
    [ Keyed.node "div" [ class "columns is-multiline" ] <| List.map (\x -> (x.uid, lazy columnView x)) xs
    ]
  

columnView : TaskItem -> Html TaskListMsg
columnView item =
  div [ class "column is-4"] [itemView item]

itemView : TaskItem -> Html TaskListMsg
itemView item =
  div [class ""] [itemCardView item]

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
