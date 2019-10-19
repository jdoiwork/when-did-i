import { TaskItem } from "../../models/task-item"

export type IDataBaseService = {
  createTaskItem(title: string): Promise<any>
  patchTaskItemDidIt(taskUid: string): Promise<any>
  
  subscribe(callback: (items: Array<[ChangeEvent, TaskItem]>) => void) : void 
  unsubscribe() : void

  getIndex() : Promise<TaskItem[]>
}

export type ChangeEvent = "create" | "update" | "delete"
