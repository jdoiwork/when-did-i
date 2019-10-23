module Helper.Cmd exposing (..)

import Tuple exposing (first)

dropCmd : (model, Cmd msg) -> model
dropCmd = first

withCmdNone : model -> (model, Cmd msg)
withCmdNone = withCmd Cmd.none

withCmd : Cmd msg -> model -> (model, Cmd msg)
withCmd cmd model = (model, cmd)
