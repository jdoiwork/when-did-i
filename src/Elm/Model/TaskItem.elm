module Model.TaskItem exposing (TaskItem, Uid, taskItemDecoder
  , decodeTaskItem, ChangeEvent(..), decodeUpdatedItems
  , encodeTaskItem)

import Time exposing (..)
import Json.Decode as D
import Json.Encode as E

type alias Uid = String

type alias TaskItem =
  { uid: Uid
  , title: String
  , lastUpdated: Posix
  }

type ChangeEvent = CreatedItem TaskItem
                 | UpdatedItem TaskItem
                 | DeletedItem TaskItem

taskItemDecoder : D.Decoder TaskItem
taskItemDecoder =
  D.map3 TaskItem
    (D.field "uid" D.string)
    (D.field "title" D.string)
    (D.field "lastUpdated" D.int |> D.map millisToPosix)

decodeTaskItem : D.Value -> (Result D.Error TaskItem)
decodeTaskItem = D.decodeValue taskItemDecoder

decodeUpdatedItems : D.Value -> (Result D.Error (List ChangeEvent))
decodeUpdatedItems =
  D.decodeValue
    (D.list
      (D.map2 (\event taskItem -> event taskItem)
        (D.index 0 D.string |> D.andThen changeEventKey)
        (D.index 1 taskItemDecoder)
        ))

changeEventKey : String -> D.Decoder (TaskItem -> ChangeEvent)
changeEventKey key =
  case key of
    "create" -> D.succeed CreatedItem
    "update" -> D.succeed UpdatedItem
    "delete" -> D.succeed DeletedItem
    _ -> D.fail "unknown change event keyword"

encodeTaskItem : TaskItem -> E.Value
encodeTaskItem item =
  E.object
    [ ("uid", E.string item.uid)
    , ("title", E.string item.title)
    , ("lastUpdated", E.int <| posixToMillis item.lastUpdated)
    ]
