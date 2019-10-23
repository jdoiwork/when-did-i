module Helper.Format exposing (..)

import Time exposing (Posix, Zone)
import DateFormat as DF
import DateFormat.Relative as DF

import Time.Extra as Ex
import Date as Ex

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
  [ DF.hourMilitaryFixed
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

type alias Parts =
    { year : Int
    , month : Int
    , day : Int
    , hour : Int
    , minute : Int
    , second : Int
    , millisecond : Int
    }

posixToParts : Zone -> Posix -> Parts
posixToParts zone posix =
  let exp = Ex.posixToParts zone posix
  in
  { year = exp.year
  , month = Ex.monthToNumber exp.month
  , day = exp.day
  , hour = exp.hour
  , minute = exp.minute
  , second = exp.second
  , millisecond = exp.millisecond
  }

partsToPosix : Zone -> Parts -> Posix
partsToPosix zone parts =
  { year = parts.year
  , month = Ex.numberToMonth parts.month
  , day = parts.day
  , hour = parts.hour
  , minute = parts.minute
  , second = parts.second
  , millisecond = parts.millisecond
  } |> Ex.partsToPosix zone