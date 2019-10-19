
import { IDataBaseService, ChangeEvent } from './types'
import { catchLogAsync } from '../../helpers/try-catch-decorator'

import * as firebase from 'firebase/app'
import 'firebase/firestore'
import { DocumentChangeType } from '@google-cloud/firestore'

export function isFirebaseUser(user: any) : boolean {
  return !!(((user || {}) as firebase.User).uid)
}

export class FireStoreDatabase implements IDataBaseService {
  db = firebase.firestore()
  fs = firebase.functions()
  callCreateTaskItem = this.fs.httpsCallable('createTaskItem')

  private _unsubscribe : () => void = () => { }

  user : firebase.User
  constructor(user: firebase.User){
    this.user = user
  }

  @catchLogAsync
  async createTaskItem(title: string): Promise<any> {
    return this.callCreateTaskItem(title)
    
  }

  private static dctTable = {
    added: "create",
    removed: "delete",
    modified: "update",
  }
  static changeEventFromDocumentChangeType(dct: DocumentChangeType) : ChangeEvent {
    return FireStoreDatabase.dctTable[dct] as ChangeEvent
  }

  subscribe(callback) : void {
    const tasks = this.db.collection('users').doc(this.user.uid).collection('tasks')
    this._unsubscribe = tasks.onSnapshot(snapshot => {
      snapshot.docChanges().map(dc => dc.type)
    })
  }

  unsubscribe() : void {
    this._unsubscribe()
  }
}

