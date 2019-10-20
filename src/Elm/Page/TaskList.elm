module Page.TaskList exposing
  ( listView
  , TaskListModel
  , taskListInit
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

type TaskListMsg = DeleteItem Uid
                 | EditItem Uid
                 | DidItItem Uid
                 | CreateItem TaskItem
                 | UpdatedItems (List ChangeEvent)
                 | UpdatedNow Posix
                 | OpenMenu TaskItemRe
                 | CloseAllMenu
                 | OpenEditForm TaskItemRe
                 | CancelEditForm String
                 | ApplyEditForm TaskItem
                 | ChangedEditingItem EditingInput
                 | Ignore

type EditingInput = TitleInput String

type alias TaskListModel =
  { items : List TaskItemRe
  , now : Posix
  , editingItem : Maybe EditingModel
  }

type alias EditingModel =
  { itemRe : TaskItemRe
  , inputTitle : String
  }

type alias TaskItemRe =
  { item : TaskItem
  , relative : String
  , isMenuOpened: Bool
  }

taskListInit : TaskListModel
taskListInit =
  { items = []
  , now = millisToPosix 0
  , editingItem = Nothing
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
       , items = List.map (updateRelative model.now) model.items
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
      | editingItem = Just { itemRe = itemRe, inputTitle = itemRe.item.title }
      } , Cmd.none)
    CancelEditForm from -> -- let _ = Debug.log "cancel edit from" from in
      ({ model
      | editingItem = Nothing
      } , Cmd.none)
    ChangedEditingItem editingInput ->
      case editingInput of
        TitleInput title ->
          ({ model
          | editingItem = model.editingItem |> Maybe.map (\item -> { item | inputTitle = title })
          }, Cmd.none)
    ApplyEditForm taskItem -> --let _ = Debug.log "ApplyEditForm" 0 in
      ({ model
      | editingItem = Nothing
      } , Cmd.none)
    _ -> (model, Cmd.none)

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
listView model =
  section [class "section"]
    [ gridListView model.items
    , editView model
    ]

gridListView : List TaskItemRe -> Html TaskListMsg
gridListView xs =
  div [ class "container"]
    [ Keyed.node "div" [ class "columns is-multiline" ] <|
      List.map (\x -> (x.item.uid, lazy columnView x)) xs
    ]
  

columnView : TaskItemRe -> Html TaskListMsg
columnView item =
  div [ class "column is-4"] [itemView item]

itemView : TaskItemRe -> Html TaskListMsg
itemView item =
  div [class ""] [itemCardView item]

itemCardView : TaskItemRe -> Html TaskListMsg
itemCardView itemRe =
  let item = itemRe.item in
  div
    -- attrs
    [ class "card"
    , id item.uid ]
    -- elements
    [ lazy itemCardViewHeader itemRe
    , lazy itemCardViewContent itemRe
    , itemCardViewFooter item
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
        [class "dropdown is-right", classList [("is-active", itemRe.isMenuOpened)]]
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

itemCardViewContent : TaskItemRe -> Html TaskListMsg
itemCardViewContent itemRe =
  div
    [ class "card-content"]
    [ p [ class "title" ] [text itemRe.relative]
    , p [ class "subtitle"] [text <| formatTime utc itemRe.item.lastUpdated]
    ]

itemCardViewFooter : TaskItem -> Html TaskListMsg
itemCardViewFooter item =
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
  in { item | title = editingModel.inputTitle }

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
            , editViewFooter
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
        , div [ class "control"]
            [ input [ class "input"
                    , type_ "text"
                    , onInput <| TitleInput >> ChangedEditingItem
                    , value model.inputTitle
                    ] []
            ]
        ]
    ]

editViewFooter : Html TaskListMsg
editViewFooter =
  footer [ class "modal-card-foot"]
    [ button [ class "button is-primary", type_ "submit"] [ text "Save changes" ]
    , button
      [ class "button"
      , onClick <| CancelEditForm "cancel button"
      ]
      [ text "Cancel" ]
    ]
