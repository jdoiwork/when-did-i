import * as admin from 'firebase-admin'

import { AuthInfo } from '../helpers/authorize'
import { HttpsError } from 'firebase-functions/lib/providers/https'

require('../helpers/firebase-init').init()


const db = admin.firestore()

function tasksRef(auth: AuthInfo) : admin.firestore.CollectionReference {
  return db
    .collection('users')
    .doc(auth.uid)
    .collection('tasks')
}

export async function createItem(title : string, auth: AuthInfo) {
  try {
    console.log("createItem::args:", {title, auth})
    const tasks = tasksRef(auth)
    
    const uid = tasks.doc().id
    console.log("createItem::tasks new ID", uid)

    const newItem = {
      uid,
      title,
      lastUpdated: Date.now(),
    }

    console.log("createItem::set newItem", newItem)
    await tasks.doc(uid).set(newItem)
    
    console.log(`createItem::set completed: ${uid}`)
    return newItem

  } catch (e) {
    console.error("Exception:!!!! createItem", { error:e, title, auth})
    throw new HttpsError('unknown', e.message, { title, auth })
  }
  
}

export async function updateDidIt(taskUid : string, auth: AuthInfo) {
  try {
    console.log("updateDidIt::args:", {taskUid, auth})
    const tasks = tasksRef(auth)
    
    const task = tasks.doc(taskUid)
    const updateItem = {
      lastUpdated: Date.now(),
    }
    console.log("updateDidIt::update updateItem", updateItem)

    await task.update(updateItem)
    
    console.log(`updateDidIt::set completed: ${taskUid}`)
    return { ...updateItem, uid: taskUid }

  } catch (e) {
    console.error("Exception:!!!! updateDidIt", { error:e, taskUid, auth})
    throw new HttpsError('unknown', e.message, { taskUid, auth })
  }
  
}
