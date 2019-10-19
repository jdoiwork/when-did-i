export type IDataBaseService = {
  createTaskItem(title: string): Promise<any> 
  subscribe(callback) : void
}

