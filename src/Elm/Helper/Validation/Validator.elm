module Helper.Validation.Validator exposing (..)

type Error e
  = Empty
  | Message String
  | Custom e

empty : String -> Result (Error e) String
empty v =
  case v of
  ""        -> Err Empty
  otherwise -> Ok v


