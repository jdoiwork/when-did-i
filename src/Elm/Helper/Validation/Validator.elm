module Helper.Validation.Validator exposing (..)

type Error e
  = Empty
  | SameInput String
  | Message String
  | Custom e

empty : String -> Result (Error e) String
empty v =
  case v of
  ""        -> Err Empty
  otherwise -> Ok v

sameInput : String -> String -> Result (Error e) String
sameInput origin v =
  if origin == v
    then Err <| SameInput origin
    else Ok v
