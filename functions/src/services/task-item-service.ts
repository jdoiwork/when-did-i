import * as admin from 'firebase-admin'

import { AuthInfo } from '../helpers/authorize'
import { HttpsError } from 'firebase-functions/lib/providers/https'

require('../helpers/firebase-init').init()


// const db = admin.firestore()

export async function createItem(title : string, auth: AuthInfo) {
  try {
    const db = admin.firestore()
    // const result = await db.collection('hellos').doc('world').set({
    //   text: 'hello world'
    // })
    // return result
    console.log("createItem::args:", {title, auth})
    const doc = await db
      .collection('users')
      .doc(auth.uid)
      // .set({
      //   uid: auth.uid,
        
      // })
      .collection('tasks')
      .add({
        title,
        lastUpdated: Date.now(),
      })
  return doc
  // await doc.update({ uid: doc.id })
  // const snap = await doc.get()
  // return snap.data()

  } catch (e) {
    console.error("Exception:!!!! createItem", e)
    throw new HttpsError('internal', e.message, { title, auth })
  }
  
}
