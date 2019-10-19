module Helper.Format exposing (..)

import Time exposing (Posix, Zone)
import DateFormat as DF
import DateFormat.Relative as DF

-- yyyy-MM-dd HH:mm:ss
tokenList : List DF.Token
tokenList =
  [ DF.yearNumber
  , DF.text "-"
  , DF.monthFixed
  , DF.text "-"
  , DF.dayOfMonthFixed
  , DF.text " "
  , DF.hourFixed  
  , DF.text ":"
  , DF.minuteFixed
  , DF.text ":"
  , DF.secondFixed
  ]

formatTime : Zone -> Posix -> String
formatTime = DF.format tokenList
-- DF.format : List Token -> Zone -> Posix -> String

formatTimeRe : Posix -> Posix -> String
formatTimeRe = DF.relativeTime
