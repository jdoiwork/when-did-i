
import { IDataBaseService, ChangeEvent } from './types'
import { catchLogAsync } from '../../helpers/try-catch-decorator'

import * as firebase from 'firebase/app'
import 'firebase/firestore'
import { TaskItem } from '../../models/task-item'

type DocumentChange = firebase.firestore.DocumentChange
type DocumentChangeType = firebase.firestore.DocumentChangeType

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

  static taskItemFromDocument(doc: any) : TaskItem {
    return { uid: doc.uid, title: doc.title, lastUpdated: doc.lastUpdated }
  }

  static updateItemFromDocumentChange(dc: DocumentChange) : [ChangeEvent, TaskItem] {
    return [ Class.changeEventFromDocumentChangeType(dc.type)
           , Class.taskItemFromDocument(dc.doc.data())]
  }

  subscribe(callback: (items: Array<[ChangeEvent, TaskItem]>) => void) : void {
    const tasks = this.db.collection('users').doc(this.user.uid).collection('tasks')
    this._unsubscribe = tasks.onSnapshot(snapshot => {
      callback(snapshot.docChanges().map(Class.updateItemFromDocumentChange))
    })
  }

  unsubscribe() : void {
    this._unsubscribe()
  }

  @catchLogAsync
  async getIndex() : Promise<TaskItem[]> {
    const tasks = this.db.collection('users').doc(this.user.uid).collection('tasks')
    const snapshot = await tasks.get()
    return snapshot.docs.map(doc => Class.taskItemFromDocument(doc.data()))
  }
}

const Class = FireStoreDatabase
