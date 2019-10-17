import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin'

import { CallableContext } from 'firebase-functions/lib/providers/https';

admin.initializeApp(functions.config().firebase)

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
export const helloWorld = functions.https.onRequest((request, response) => {
 response.send("Hello from Firebase!");
});

export const helloFromWeb = functions.https.onCall((data:any, context: CallableContext) : any => {
  return {
    data,
    context: { auth: context.auth, instanceIdToken: context.instanceIdToken }
  }
})

export const createHelloItem = functions.https.onRequest(async (req, res) => {
  try {
    const db = admin.firestore()

    const result = await db.collection('hellos').doc('world').set({
      text: 'hello world'
    })
    res.json({
      ok: 'ok',
      result
    })
  }
  catch (error) {
    res.json({
      err: 'err',
      error: error,
    })
  }

})
