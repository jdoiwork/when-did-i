module Helper.Validation exposing (..)

import Json.Decode as D

type alias ValidationTarget error value =
  { rawValue : String -- Raw value from input element
  , result : Result error value -- View Model for Html msg
  }

-- MEMO:
-- on : String -> Decoder msg -> Attribute msg
-- onInput : (String -> msg) -> Attribute msg
-- onCheck : (Bool -> msg) -> Attribute msg
