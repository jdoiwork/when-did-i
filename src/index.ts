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
  auth.signIn()
})

auth.subscribe(async ({user, status}) => {
  db.unsubscribe()
  db = DatabaseServiceFactory.createService(user)
  app.loginStatusChanged(status)
  if (false) {
  const items = await db.getIndex()
  console.log("getIndex", items)

  }
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
  console.log(title)
  // const item = await db.postItem(title)
  db.createTaskItem(title).then(console.log).catch(e => console.error)
  // app.createdNewItem(item)
  // console.log("new item", item)
})

app.patchItemDidIt(uid => {
  console.log("patch did it", uid)
})

window["app"] = app

import * as firebase from "firebase/app"
window["firebase"] = firebase
const fs = firebase.functions()
window["onCalls"] = {
  ok: fs.httpsCallable("ok"),
  err: fs.httpsCallable("err"),
  helloFromWeb: fs.httpsCallable("helloFromWeb"),
}

window["onCalls"].ok("ok dayo").then(a => console.log(a)).catch(e => console.error(e))
