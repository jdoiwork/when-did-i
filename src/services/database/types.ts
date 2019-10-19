export type IDataBaseService = {
  createTaskItem(title: string): Promise<any> 
  subscribe(callback) : void
  unsubscribe() : void
}

export type ChangeEvent = "create" | "update" | "delete"
