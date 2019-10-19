
import { IDataBaseService } from './types'
import { catchLogAsync } from '../../helpers/try-catch-decorator'

import * as firebase from 'firebase/app'
import 'firebase/firestore'

export function isFirebaseUser(user: any) : boolean {
  return !!(((user || {}) as firebase.User).uid)
}

export class FireStoreDatabase implements IDataBaseService {
  db = firebase.firestore()
  fs = firebase.functions()
  callCreateTaskItem = this.fs.httpsCallable('createTaskItem')
  user : firebase.User
  constructor(user: firebase.User){
    this.user = user
  }

  @catchLogAsync
  async createTaskItem(title: string): Promise<any> {
    return this.callCreateTaskItem(title)
    
  }

  subscribe(callback) : void {
    
  }
}

