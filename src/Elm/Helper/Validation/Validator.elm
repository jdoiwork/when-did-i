module Helper.Validation.Validator exposing (..)

type ValidateError e = Empty
                     | Message String
                     | Custom e

