import { TaskItem } from "../../models/task-item"

export type IDataBaseService = {
  createTaskItem(title: string): Promise<any> 
  subscribe(callback: (items: Array<[ChangeEvent, TaskItem]>) => void) : void 
  unsubscribe() : void
}

export type ChangeEvent = "create" | "update" | "delete"
