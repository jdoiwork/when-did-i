module Helper.Validation exposing (..)

import Json.Decode as D
import Helper.Validation.Validator as V

type alias ValidationTarget e value =
  { rawValue : String -- Raw value from input element
  , result : Result (V.ValidateError e) value -- View Model for Html msg
  }




withValidate : (String -> Result (V.ValidateError e) value) -> String -> ValidationTarget e value
withValidate validator rawValue =
  { rawValue = rawValue
  , result = validator rawValue
  }

-- MEMO:
-- on : String -> Decoder msg -> Attribute msg
-- onInput : (String -> msg) -> Attribute msg
-- onCheck : (Bool -> msg) -> Attribute msg
