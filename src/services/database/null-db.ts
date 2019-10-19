
import { IDataBaseService, ChangeEvent } from './types'
import { catchLogAsync } from '../../helpers/try-catch-decorator'
import { TaskItem } from '../../models/task-item'

export class NullDatabase implements IDataBaseService {

  @catchLogAsync
  async createTaskItem(title: string): Promise<any> {
    return { data: "null database" }
  }

  subscribe(_callback: (items: Array<[ChangeEvent, TaskItem]>) => void) : void {
    
  }

  unsubscribe() : void {

  }
}

