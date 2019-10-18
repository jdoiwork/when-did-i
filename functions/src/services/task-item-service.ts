import * as admin from 'firebase-admin'

import { AuthInfo } from '../helpers/authorize'
import { HttpsError } from 'firebase-functions/lib/providers/https'

require('../helpers/firebase-init').init()


const db = admin.firestore()

export async function createItem(title : string, auth: AuthInfo) {
  try {
    console.log("createItem::args:", {title, auth})
    const tasks = db
      .collection('users')
      .doc(auth.uid)
      .collection('tasks')
    
    const uid = tasks.doc().id
    const newItem = {
      uid,
      title,
      lastUpdated: Date.now(),
    }
    await tasks.doc(uid).set(newItem)
    
    return newItem
      // await doc.update({ uid: doc.id })
      // const snap = await doc.get()
      // return snap.data()

  } catch (e) {
    console.error("Exception:!!!! createItem", e)
    throw new HttpsError('internal', e.message, { title, auth })
  }
  
}
