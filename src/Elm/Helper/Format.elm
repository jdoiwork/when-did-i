module Helper.Format exposing (..)

import Time exposing (Posix, Zone)
import DateFormat as DF
import DateFormat.Relative as DF

-- yyyy-MM-dd HH:mm:ss
tokenList : List DF.Token
tokenList = List.concat
  [ tokenDateList
  , [DF.text " "]
  , tokenTimeList
  ]

tokenDateList : List DF.Token
tokenDateList =
  [ DF.yearNumber
  , DF.text "-"
  , DF.monthFixed
  , DF.text "-"
  , DF.dayOfMonthFixed
  ]

tokenTimeList : List DF.Token
tokenTimeList =
  [ DF.hourMilitaryFromOneFixed  
  , DF.text ":"
  , DF.minuteFixed
  , DF.text ":"
  , DF.secondFixed
  ]

formatDateTime : Zone -> Posix -> String
formatDateTime = DF.format tokenList

formatDate : Zone -> Posix -> String
formatDate = DF.format tokenDateList

formatTime : Zone -> Posix -> String
formatTime = DF.format tokenTimeList
-- DF.format : List Token -> Zone -> Posix -> String

formatTimeRe : Posix -> Posix -> String
formatTimeRe = DF.relativeTime
