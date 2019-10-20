import './inits/css-init'
import * as auth from './services/auth'

import { ElmAppAdapter } from './helpers/elm-app-adapter'

import {init as firebaseInit } from "./inits/firebase-init"


import * as DatabaseServiceFactory from './services/database-service-factory'

firebaseInit()

const app = new ElmAppAdapter({})

let db = DatabaseServiceFactory.createService()


app.loginWith(provider => {
  console.log(`${provider} login`)
  auth.signIn(provider)
})

auth.subscribe(async ({user, status}) => {
  db.unsubscribe()
  db = DatabaseServiceFactory.createService(user)
  app.loginStatusChanged(status)

  db.subscribe(newItems => {
    console.log("subscribe", newItems)
    app.updatedItems(newItems)
  })
})

app.logout(() => {
  console.log("logout")
  auth.signOut()
})

app.postNewItem(async title => {
  db.createTaskItem(title).then(console.log).catch(e => console.error)
})

app.patchItemDidIt(uid => {
  afterPatched('patchItemDidIt', uid, db.patchTaskItemDidIt(uid))
})

app.patchItem(taskItem => {
  afterPatched('patchItem', taskItem.uid, db.patchTaskItem(taskItem))
})

async function afterPatched(key: String, uid: String, promise: Promise<any>) {
  try {
    const result = await promise
    console.log(key, uid, result)
  } catch (e) {
    console.error(key, uid, e.message)
  }

  app.notifyTaskItemIsUpdated(uid)
}

app.deleteItem(uid => {
  db.deleteItem(uid).then(console.log).catch(console.error)
})
