import * as functions from 'firebase-functions';

import { CallableContext } from 'firebase-functions/lib/providers/https';

import { authorize, error403 } from './helpers/authorize'

import * as TaskItemService from './services/task-item-service'

require('./helpers/firebase-init').init()


export const ok = functions.https.onCall(async (data: any, context: CallableContext) => {
  await authorize(context)
  return { ok: 'ok', requestData: data }
})

export const err = functions.https.onCall(async (data: any, context: CallableContext) => {
  await authorize(context)
  throw error403()
})

// -------------------------------------------------------- for Task Items

const createOnCall = (f : (data: any, context: CallableContext) => any) => functions.https.onCall(f)

export const createTaskItem = createOnCall(async (request, context) => {
  const authInfo = await authorize(context)
  console.log("createTaskItem", request)
  
  const item = await TaskItemService.createItem(request, authInfo)
  return { message: "task item created", item: item }
})

export const updateTaskItemDidIt = createOnCall(async (request, context) => {
  const authInfo = await authorize(context)
  console.log("updateDidIt", request)
  
  const item = await TaskItemService.updateDidIt(request, authInfo)
  return { message: "task item created", item: item }
})
