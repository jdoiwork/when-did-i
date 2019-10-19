import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin'

import { CallableContext } from 'firebase-functions/lib/providers/https';

import { authorize, error403 } from './helpers/authorize'

import * as TaskItemService from './services/task-item-service'

// admin.initializeApp(functions.config().firebase)
require('./helpers/firebase-init').init()

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

export const ok = functions.https.onCall(async (data: any, context: CallableContext) => {
  await authorize(context)
  return { ok: 'ok', requestData: data }
})

export const err = functions.https.onCall(async (data: any, context: CallableContext) => {
  await authorize(context)
  throw error403()
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

// -------------------------------------------------------- for Task Items

const createOnCall = (f : (data: any, context: CallableContext) => any) => functions.https.onCall(f)

export const createTaskItem = createOnCall(async (request, context) => {
  const authInfo = await authorize(context)
  console.log("createTaskItem", request)
  
  const item = await TaskItemService.createItem(request, authInfo)
  return { message: "task item created", item: item }
})
