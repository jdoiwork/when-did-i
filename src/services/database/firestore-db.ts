
import { IDataBaseService } from './types'

import * as firebase from 'firebase/app'
import 'firebase/firestore'

export class FireStoreDatabase implements IDataBaseService {
  db = firebase.firestore()
  fs = firebase.functions()
  callCreateTaskItem = this.fs.httpsCallable('createTaskItem')

  async createTaskItem(title: string): Promise<void> {
    //this.db.collection('users').doc(user.uid)
    
  }
}

