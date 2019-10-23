module Helper.Cmd exposing (..)

import Tuple exposing (first)

dropCmd : (model, Cmd msg) -> model
dropCmd = first

withCmdNone : model -> (model, Cmd msg)
withCmdNone model = (model, Cmd.none)
