module Page.TaskList exposing (listView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time exposing (..)

type alias TaskItem =
  { uid: Uid
  , title: String
  , lastUpdated: Posix
  }

type alias Uid = String

type TaskItemMsg = Delete Uid
                 | Edit Uid
                 | DoneAgain Uid

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

listView : Html TaskItemMsg
listView =
  let items = split3 dummyTasks
  in section [class "section"] <| List.map gridListView items

gridListView : List TaskItem -> Html TaskItemMsg
gridListView xs =
  div [ class "container"]
    [div [ class "columns" ] <| List.map columnView xs]
  

columnView : TaskItem -> Html TaskItemMsg
columnView item =
  div [ class "column is-4"] [itemView item]

parentTileView : List TaskItem -> Html TaskItemMsg
parentTileView items =
  div [class "tile is-parent is-vertical_"] <| List.map itemView items

itemView : TaskItem -> Html TaskItemMsg
itemView item =
  div [class "tile is-child box_"] [itemCardView item]

itemCardView : TaskItem -> Html TaskItemMsg
itemCardView item =
  div
    [ class "card", id item.uid ]
    [ header
        [class "card-header"]
        [ p [ class "card-header-title" ] [ text item.title] ]
    , div
        [ class "card-content"]
        [ text "2019/10/16 12:34:56"]
    , footer
        [ class "card-footer"]
        [ a [ class "card-footer-item", onClick <| Delete item.uid, href "#" ] [ text "delete"]
        , a [ class "card-footer-item", onClick <| Delete item.uid, href "#" ] [ text "Edit"]
        , a [ class "card-footer-item", onClick <| Delete item.uid, href "#" ] [ text "Done Again!"]
        ]
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