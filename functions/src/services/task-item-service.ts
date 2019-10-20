import * as admin from 'firebase-admin'

import { AuthInfo } from '../helpers/authorize'
import { HttpsError } from 'firebase-functions/lib/providers/https'
import { TaskItem } from '../models/task-item'

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

export async function updateTaskItem(item : TaskItem, auth: AuthInfo) {
  try {
    console.log("updateDidIt::args:", {item, auth})
    const tasks = tasksRef(auth)
    const uid = item.uid
    const task = tasks.doc(item.uid)

    // validations
    const safeTitle = String(item.title || "")

    if (!safeTitle) {
      throw new Error("TaskItem.title is empty.")
    } else if (!Number.isSafeInteger(item.lastUpdated)) {
      throw new Error(`TaskItem.lastUpdated is NOT valid POSIX TIME(${item.lastUpdated}).`)
    }

    // const snap = await task.get()
    //snap.exists
    const updateItem = {
      uid: item.uid,
      title: safeTitle,
      lastUpdated: item.lastUpdated,
    }
    // console.log("updateDidIt::update updateItem", updateItem)

    await task.update(updateItem)
    
    console.log(`updateDidIt::set completed: ${uid}`)
    return item

  } catch (e) {
    console.error("Exception:!!!! updateDidIt", { error:e, item, auth})
    throw new HttpsError('unknown', e.message, { item, auth })
  }
  
}
