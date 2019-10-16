module Model.TaskItem exposing (TaskItem, Uid, taskItemDecoder, decodeTaskItem)

import Time exposing (..)
import Json.Decode as D

type alias Uid = String

type alias TaskItem =
  { uid: Uid
  , title: String
  , lastUpdated: Posix
  }

taskItemDecoder : D.Decoder TaskItem
taskItemDecoder =
  D.map3 TaskItem
    (D.field "uid" D.string)
    (D.field "title" D.string)
    (D.field "lastUpdated" D.int |> D.map millisToPosix)

decodeTaskItem : D.Value -> (Result D.Error TaskItem)
decodeTaskItem = D.decodeValue taskItemDecoder

