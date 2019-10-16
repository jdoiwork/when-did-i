

import { TaskItem } from '../models/task-item'

async function postItem(title: string) : Promise<TaskItem> {
  const dt = Date.now()
  return {
    uid: dt.toString(),
    title: title,
    lastUpdated: dt,
  }
}

export { postItem }
