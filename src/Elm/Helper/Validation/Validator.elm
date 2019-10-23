module Helper.Validation.Validator exposing (..)

type Error e
  = Empty
  | SameInput String
  | ToInt String
  | IntRange Int Int Int
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

toInt : String -> Result (Error e) Int
toInt v =
  case String.toInt v of
    Nothing -> Err <| ToInt v
    Just n -> Ok n

intRange : Int -> Int -> Int -> Result (Error e) Int
intRange from to n =
  if from <= n && n <= to
    then Ok n
    else Err <| IntRange from to n
