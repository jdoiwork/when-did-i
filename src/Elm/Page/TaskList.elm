module Page.TaskList exposing
  ( listView
  , TaskListModel
  , taskListInit
  , taskListInitWithOutTime
  , TaskListMsg(..)
  , updateTaskList
  )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Html.Lazy exposing (..)
import Maybe exposing (..)
import Json.Decode as Json

import Time exposing (..)

import Model.TaskItem exposing (..)

import Helper.Format exposing (..)
import Helper.Validation exposing (..)
import Helper.Validation.Validator as V
import Helper.Cmd exposing (..)

import Result.Extra exposing (isErr)

type TaskListMsg = DeleteItem Uid
                 | EditItem Uid
                 | DidItItem Uid
                 | CreateItem TaskItem
                 | UpdatedItems (List ChangeEvent)
                 | UpdatedNow Posix
                 | UpdatedZone Zone
                 | OpenMenu TaskItemRe
                 | CloseAllMenu
                 | OpenEditForm TaskItemRe
                 | CancelEditForm String
                 | ApplyEditForm TaskItem
                 | ChangedEditingItem EditingInput
                 | TaskItemIsUpdated Uid
                 | Ignore

type EditingInput = TitleInput EditingModel String
                  | YearInput EditingModel String
                  | MonthInput EditingModel String
                  | DayInput EditingModel String
                  | HourInput EditingModel String
                  | MinuteInput EditingModel String
                  | SecondInput EditingModel String

type alias TaskListModel =
  { items : List TaskItemRe
  , now : Posix
  , zone : Zone
  , editingItem : Maybe EditingModel
  }

type alias EditingModel =
  { itemRe : TaskItemRe
  , inputTitle : ValidationTarget String String
  , inputYear : ValidationTarget String Int
  , inputMonth : ValidationTarget String Int
  , inputDay : ValidationTarget String Int
  , inputHour : ValidationTarget String Int
  , inputMinute : ValidationTarget String Int
  , inputSecond : ValidationTarget String Int
  , inputLastUpdated : Parts
  }

type alias TaskItemRe =
  { item : TaskItem
  , relative : String
  , isMenuOpened: Bool
  , isUpdating: Bool
  }

taskListInit : TaskListModel
taskListInit =
  { items = []
  , now = millisToPosix 0
  , zone = utc
  , editingItem = Nothing
  }

taskListInitWithOutTime : TaskListModel -> TaskListModel
taskListInitWithOutTime model =
  { model
  | now = model.now
  , zone = model.zone
  }

updateTaskList : TaskListMsg -> TaskListModel -> ( TaskListModel, Cmd TaskListMsg )
updateTaskList msg model =
  case msg of
    UpdatedItems ces ->
      let newModels = mergeItems model.now ces model.items
      in ({model | items = newModels }, Cmd.none)
    UpdatedNow now ->
      ({ model
       | now = now
       , items = List.map (updateRelative now) model.items
       } , Cmd.none)
    UpdatedZone zone ->
      ({ model
       | zone = zone
       } , Cmd.none)
    OpenMenu target ->
      ({ model
      | items = updateItemsOfMenu (Just target) model.items
      } , Cmd.none)
    CloseAllMenu -> -- let _ = Debug.log "close all menu" "" in
      ({ model
      | items = updateItemsOfMenu (Nothing) model.items
      -- | items = model.items
      } , Cmd.none)
    OpenEditForm itemRe ->
      let inputLastUpdated = posixToParts model.zone itemRe.item.lastUpdated
          vt getter = ValidationTarget (String.fromInt <| getter inputLastUpdated) (Ok <| getter inputLastUpdated)
      in
      ({ model
      | editingItem = Just { itemRe = itemRe
                           , inputTitle = ValidationTarget itemRe.item.title <| Ok itemRe.item.title

                           , inputYear = vt .year
                           , inputMonth = vt .month
                           , inputDay = vt .day

                           , inputHour = vt .hour 
                           , inputMinute = vt .minute
                           , inputSecond = vt .second

                           , inputLastUpdated = inputLastUpdated
                           }
      } , Cmd.none)
    CancelEditForm from -> -- let _ = Debug.log "cancel edit from" from in
      ({ model
      | editingItem = Nothing
      } , Cmd.none)

    -- 編集中のアイテムの入力要素が変更されたら
    ChangedEditingItem editingInput ->
      let newEditingItem =
            case editingInput of
              TitleInput editingItem title ->
                { editingItem | inputTitle = title |> withValidate (validateInputTitle editingItem) }

              YearInput editingItem year ->
                { editingItem | inputYear  = year  |> withValidate (validateInputYear editingItem) }
              MonthInput editingItem month ->
                { editingItem | inputMonth  = month  |> withValidate (validateInputMonth editingItem) }
              DayInput editingItem day ->
                { editingItem | inputDay  = day  |> withValidate (validateInputDay editingItem) }

              HourInput editingItem hour ->
                { editingItem | inputHour  = hour  |> withValidate (validateInputHour editingItem) }
              MinuteInput editingItem minute ->
                { editingItem | inputMinute  = minute  |> withValidate (validateInputMinute editingItem) }
              SecondInput editingItem second ->
                { editingItem | inputSecond  = second  |> withValidate (validateInputSecond editingItem) }
      in
      { model
      | editingItem = Just newEditingItem
      } |> withCmdNone

    ApplyEditForm taskItem -> --let _ = Debug.log "ApplyEditForm" 0 in
      ({ model
      | editingItem = Nothing
      , items = markUpdating taskItem.uid model.items
      } , Cmd.none)
    DidItItem uid ->
      ({ model
      | items = markUpdating uid model.items
      } , Cmd.none)
    TaskItemIsUpdated uid -> --let _ = Debug.log "TaskItemIsUpdated" uid in
      ({ model
      | items = unmarkUpdating uid model.items
      } , Cmd.none)
    _ -> (model, Cmd.none)

markUpdating : Uid -> List TaskItemRe -> List TaskItemRe
markUpdating = markUpdatingCore True

unmarkUpdating : Uid -> List TaskItemRe -> List TaskItemRe
unmarkUpdating = markUpdatingCore False

markUpdatingCore : Bool -> Uid -> List TaskItemRe -> List TaskItemRe
markUpdatingCore isUpdating uid items =
  let f itemRe =
        if itemRe.item.uid == uid
          then { itemRe | isUpdating = isUpdating }
          else itemRe
  in List.map f items

updateItemsOfMenu : Maybe TaskItemRe -> List TaskItemRe -> List TaskItemRe
updateItemsOfMenu target items =
  let toggle item = target == Just item      -- 別のアイテムならメニューを閉じる
                    && not item.isMenuOpened -- 同じアイテムだったらメニューの開閉を逆にする
  in
  List.map (\item -> { item | isMenuOpened = toggle item }) items


updateRelative : Posix -> TaskItemRe -> TaskItemRe
updateRelative now itemRe =
  let newRelative = formatTimeRe now itemRe.item.lastUpdated
  in if itemRe.relative /= newRelative
        then { itemRe | relative = newRelative}
        else itemRe

mkTaskItemRe : Posix -> TaskItem -> TaskItemRe
mkTaskItemRe now item = { item = item
                        , relative = formatTimeRe now item.lastUpdated
                        , isMenuOpened = False
                        , isUpdating = False
                        }

mergeItems : Posix -> List ChangeEvent -> List TaskItemRe -> List TaskItemRe
mergeItems now ces ts =
  case ces of
    [] -> ts
    (ce :: ces_) -> mergeItems now ces_ <| case ce of
      CreatedItem item -> (mkTaskItemRe now item)::ts
      UpdatedItem item -> List.map (\t -> if t.item.uid == item.uid && t.item /= item then mkTaskItemRe now item else t) ts
      DeletedItem item -> List.filter (\t -> t.item.uid /= item.uid) ts

listView : TaskListModel -> Html TaskListMsg
listView model = --let _ = Debug.log "listView zone:" model.zone in
  section [class "section"]
    [ gridListView model.zone model.items
    , editView model
    ]

gridListView : Zone -> List TaskItemRe -> Html TaskListMsg
gridListView zone xs =
  div [ class "container"]
    [ Keyed.node "div" [ class "columns is-multiline" ] <|
      List.map (\x -> (x.item.uid, lazy2 columnView zone x)) xs
    ]
  

columnView : Zone -> TaskItemRe -> Html TaskListMsg
columnView zone item =
  div [ class "column is-4"] [itemView zone item]

itemView : Zone -> TaskItemRe -> Html TaskListMsg
itemView zone item =
  div [class ""] [itemCardView zone item]

itemCardView : Zone -> TaskItemRe -> Html TaskListMsg
itemCardView zone itemRe =
  let item = itemRe.item in
  div
    -- attrs
    [ class "card"
    , id item.uid ]
    -- elements
    [ lazy itemCardViewHeader itemRe
    , lazy2 itemCardViewContent zone itemRe
    , itemCardViewFooter itemRe
    ]

alwaysPreventDefault : msg -> ( msg, Bool )
alwaysPreventDefault msg =
  ( msg, True )

onClickPrevent : msg -> Attribute msg
onClickPrevent msg =
  stopPropagationOn "click" (Json.map alwaysPreventDefault (Json.succeed msg))


itemCardViewHeader : TaskItemRe -> Html TaskListMsg
itemCardViewHeader itemRe =
  let item = itemRe.item in
  header
    [class "card-header"]
    [ p [ class "card-header-title" ] [ text item.title ]
    , div
        [ class "dropdown is-right"
        , classList [("is-active", itemRe.isMenuOpened), ("is-hidden", itemRe.isUpdating)]
        ]
        [ div
            [ class "dropdown-trigger" ]
            [ div
                [ ]
                [ a [ class "card-header-icon"
                    , onClickPrevent <| OpenMenu itemRe
                    ]
                    [ ionIcon "ios-arrow-dropdown" ]
                ]
            ]
        , div
            [ class "dropdown-menu" ]
            [ div
                [ class "dropdown-content" ]
                [ a [ class "dropdown-item" -- 編集メニュー
                    , onClick <| OpenEditForm itemRe
                    ]
                    [ ionIcon "ios-create", text "Edit" ]
                , a [ class "dropdown-item has-text-danger" -- 削除メニュ
                    , onClick <| DeleteItem item.uid
                    ]
                    [ ionIcon "ios-trash", text "Delete" ]
                ]
            ]
        ]

    ]

itemCardViewContent : Zone -> TaskItemRe -> Html TaskListMsg
itemCardViewContent zone itemRe =
  div
    [ class "card-content"]
    [ p [ class "title is-capitalized diff-time" ] [text itemRe.relative]
    , p [ class "subtitle has-text-dark-grey date-container"]
        [ node "date" [ ]
            [ span [ class ""] [text <| formatDate zone itemRe.item.lastUpdated]
            , text " "
            , span [ class "is-italic"] [text <| formatTime zone itemRe.item.lastUpdated]
            ]
        ]
    ]

itemCardViewFooter : TaskItemRe -> Html TaskListMsg
itemCardViewFooter itemRe =
  let item = itemRe.item in
  footer
    -- footer attrs
    [ class "card-footer"
    , style "justify-content" "center"
    ]
    -- footer elements
    [ p
        -- p attrs
        [ class "card-footer-item", style "padding" "5px 0"]
        -- p elements
        [ div
            [ class "buttons"]
            [ actionButton "ios-checkmark-circle-outline"
                [ class "is-primary"
                , classList [("is-loading", itemRe.isUpdating)]
                , onClick <| DidItItem item.uid
                ]
                "More"
            ]
        ]
    ]

actionButton : String -> List (Attribute a) -> String -> Html a
actionButton iconName attrs content =
  button
    ([ class "button is-rounded is-small" ] ++ attrs)
    [ ionIcon iconName
    , span [] [ text content]
    ]

ionIcon : String -> Html a
ionIcon iconName =
  span [ class "icon" ]
    [ i [class "icon", class <| "ion-" ++ iconName]
      []]

createTaskItemFromEditing : EditingModel -> TaskItem
createTaskItemFromEditing editingModel =
  let item = editingModel.itemRe.item
  in { item | title = editingModel.inputTitle.rawValue }

editView : TaskListModel -> Html TaskListMsg
editView model =
  case model.editingItem of
    Nothing -> text "" -- show nothing
    Just editingItem ->
      Html.form [ onSubmit <| ApplyEditForm <| createTaskItemFromEditing editingItem ]
      [ div [ class "modal is-active"]
        [ div [ class "modal-background", onClick <| CancelEditForm "modal-background" ] []
        , div [ class "modal-card" ]
            [ editViewHeader editingItem
            , editViewContent editingItem
            , editViewFooter editingItem
            ]
        ]
      ]

editViewHeader : EditingModel -> Html TaskListMsg
editViewHeader model =
  header [ class "modal-card-head"]
    [ p [ class "modal-card-title"] [ text model.itemRe.item.title ]
    , button
        [ class "delete"
        , type_ "button"
        , attribute "aria-label" "close"
        , onClick <| CancelEditForm "X button"
        ]
        []
    ]

editViewContent : EditingModel -> Html TaskListMsg
editViewContent model =
  section [ class "modal-card-body"]
    [ div [ class "field"]
        [ label [ class "label"] [ text "Title" ]
        , editTitleInput model
        ]
    , div [ class "field datetime-input"]
        [ label [ class "label"] [ text "Date" ]
        , editDateInput model
        ]
    , div [ class "field datetime-input"]
        [ label [ class "label"] [ text "Time" ]
        , editTimeInput model
        ]
    ]

editTitleInput : EditingModel -> Html TaskListMsg
editTitleInput model =
  div [ class "control"]
    [ input [ class "input"
            , type_ "text"
            , onInput <| TitleInput model >> ChangedEditingItem
            , value model.inputTitle.rawValue
            ]
            [
            ]
    ]

editDateInput : EditingModel -> Html TaskListMsg
editDateInput model =
  let lu = model.inputLastUpdated
  in
  div [ class "field is-grouped" ]
    [ div [ class "control"] -- YEAR
        [ input [ class "input"
                , type_ "number"
                , value model.inputYear.rawValue
                , onInput <| YearInput model >> ChangedEditingItem
                , classList [("is-danger", isErr model.inputYear.result)]
                ]
                [
                ]
        ]
    , div [ class "control"]
        [ label [ class "is-static input is-centered" ]
            [ div [] [text "-"]]
        ]
    , div [ class "control"]
        [ div [ class "select"]
            [ select [ ] <| numberOptions 1 12 lu.month ]
        ]
    , div [ class "control"]
        [ label [ class "input is-static is-centered" ]
            [ text "-" ]
        ]

    , div [ class "control" ]
        [ div [ class "select" ]
            [ select [ ] <| numberOptions 1 31 lu.day ]
        ]
    ]

numberOptions : Int -> Int -> Int -> List (Html a)
numberOptions from to selectedValue =
  List.range from to
    |> List.map (\n -> option [ valueFromInt n, selected <| n == selectedValue ] [ text <| String.fromInt n ])

valueFromInt : Int -> Attribute msg
valueFromInt = String.fromInt >> value 


editTimeInput : EditingModel -> Html TaskListMsg
editTimeInput model =
  let lu = model.inputLastUpdated
  in
  div [ class "field is-grouped" ]
    [ div [ class "control"]
        [ div [ class "select"]
            [ select [ ] <| numberOptions 0 23 lu.hour ]
        ]

    , div [ class "control"]
        [ label [ class "is-static input is-centered" ]
            [ div [] [text ":"]]
        ]
    , div [ class "control"]
        [ div [ class "select"]
            [ select [ ] <| numberOptions 0 59 lu.minute]
        ]
    , div [ class "control"]
        [ label [ class "input is-static is-centered" ]
            [ text ":" ]
        ]

    , div [ class "control" ]
        [ div [ class "select" ]
            [ select [ ] <| numberOptions 0 59 lu.second]
        ]
    ]

validateInputTitle : EditingModel -> String -> Result (V.Error e) String
validateInputTitle model rawValue =
  let title = model.itemRe.item.title in
  rawValue
    |> V.sameInput title
    |> Result.andThen V.empty

validateInputYear : EditingModel -> String -> Result (V.Error e) Int
validateInputYear model rawValue =
  --let year = String.fromInt model.inputLastUpdated.year in
  rawValue
    |> V.empty
    |> Result.andThen V.toInt


validateInputMonth : EditingModel -> String -> Result (V.Error e) Int
validateInputMonth = validateInputRange 1 12

validateInputDay : EditingModel -> String -> Result (V.Error e) Int
validateInputDay = validateInputRange 1 31

validateInputHour : EditingModel -> String -> Result (V.Error e) Int
validateInputHour = validateInputRange 0 23

validateInputMinute : EditingModel -> String -> Result (V.Error e) Int
validateInputMinute = validateInputRange 0 59

validateInputSecond : EditingModel -> String -> Result (V.Error e) Int
validateInputSecond = validateInputRange 0 59


validateInputRange : Int -> Int -> EditingModel -> String -> Result (V.Error e) Int
validateInputRange from to model rawValue =
  rawValue
    |> V.empty
    |> Result.andThen V.toInt
    |> Result.andThen (V.intRange from to)

editViewFooter : EditingModel -> Html TaskListMsg
editViewFooter model =
  footer [ class "modal-card-foot"]
    [ button
      [ class "button"
      , type_ "button"
      , onClick <| CancelEditForm "cancel button"
      ]
      [ text "Cancel" ]
    , button 
      [ class "button is-primary"
      , type_ "submit"
      , disabled <| isErr model.inputTitle.result
      ]
      [ text "Save changes" ]
    ]
