module Helper.Validation.Validator exposing (..)

type Error e
  = Empty
  | Message String
  | Custom e

