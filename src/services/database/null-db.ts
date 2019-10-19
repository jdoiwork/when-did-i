
import { IDataBaseService, ChangeEvent } from './types'
import { TaskItem } from '../../models/task-item'

export class NullDatabase implements IDataBaseService {

  async createTaskItem(title: string): Promise<any> {
    return { data: "null database" }
  }

  async patchTaskItemDidIt(taskUid: string): Promise<any> {
    return { data: "null database"}
  }

  async deleteItem(taskUid: string): Promise<any> {
    return { data: "null database"}
  }

  subscribe(_callback: (items: Array<[ChangeEvent, TaskItem]>) => void) : void {
    
  }

  unsubscribe() : void {

  }

  async getIndex() : Promise<TaskItem[]> {
    return []
  }
}

