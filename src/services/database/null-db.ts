
import { IDataBaseService } from './types'
import { catchLogAsync } from '../../helpers/try-catch-decorator'

export class NullDatabase implements IDataBaseService {

  @catchLogAsync
  async createTaskItem(title: string): Promise<any> {
    return { data: "null database" }
  }
}

