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
                  | LastUpdateInput Parts

type alias TaskListModel =
  { items : List TaskItemRe
  , now : Posix
  , zone : Zone
  , editingItem : Maybe EditingModel
  }

type alias EditingModel =
  { itemRe : TaskItemRe
  , inputTitle : ValidationTarget String String
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
      ({ model
      | editingItem = Just { itemRe = itemRe
                           , inputTitle = ValidationTarget itemRe.item.title <| Ok itemRe.item.title
                           , inputLastUpdated = posixToParts model.zone itemRe.item.lastUpdated
                           }
      } , Cmd.none)
    CancelEditForm from -> -- let _ = Debug.log "cancel edit from" from in
      ({ model
      | editingItem = Nothing
      } , Cmd.none)

    -- 編集中のアイテムの入力要素が変更されたら
    ChangedEditingItem editingInput ->
      case editingInput of
        TitleInput editingItem title ->
          let validateTitle = title |> withValidate (validateInputTitleR editingItem.itemRe.item.title) in
          { model
          | editingItem = Just { editingItem | inputTitle = validateTitle }
          } |> withCmdNone
        LastUpdateInput lu ->
          { model
          | editingItem = model.editingItem |> Maybe.map (\item -> { item | inputLastUpdated = lu })
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
    [ div [ class "control"]
        [ input [ class "input", type_ "number", valueFromInt lu.year ] [] ]
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



-- on : String -> Decoder msg -> Attribute msg
onChangeNum : Int -> Int -> EditingModel -> (Parts -> Int -> Parts) -> Attribute TaskListMsg
onChangeNum from to editingModel f =
  let maybeError a =
        case a of
          Just x -> Json.succeed x
          Nothing -> Json.fail "not integer"
  in
  targetValue
    |> Json.map String.toInt
    |> Json.andThen maybeError
    |> Json.map (\n -> ChangedEditingItem <| LastUpdateInput  (f editingModel.inputLastUpdated n))
    |> on "change"

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

validateInputTitle : EditingModel -> Bool
validateInputTitle model =
  model.inputTitle.rawValue == model.itemRe.item.title -- 元の入力値と同じ
    || model.inputTitle.rawValue == "" -- 入力値が空文字列

validateInputTitleR : String -> String -> Result (V.Error e) String
validateInputTitleR title rawValue =
  let sameInput v =
        if v == title
          then Err <| V.Message ""
          else Ok rawValue
      empty v =
        if v == ""
          then Err <| V.Message "empty"
          else Ok v
  in sameInput rawValue |> Result.andThen empty


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
      , disabled <| validateInputTitle model
      ]
      [ text "Save changes" ]
    ]
