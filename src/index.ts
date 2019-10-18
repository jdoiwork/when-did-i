import './inits/css-init'
import * as auth from './services/auth'
import * as db from './services/dummy-database'

import { ElmAppAdapter } from './helpers/elm-app-adapter'

import {init as firebaseInit } from "./inits/firebase-init"

firebaseInit()

const app = new ElmAppAdapter({})

app.loginWith(provider => {
  console.log(`${provider} login`)
  auth.signIn()
})

auth.subscribe((user) => {
  const status = user ? "login" : "logout"
  app.loginStatusChanged(status)
})

app.logout(() => {
  console.log("logout")
  auth.signOut()
})

app.postNewItem(async title => {
  console.log(title)
  const item = await db.postItem(title)
  app.createdNewItem(item)
  console.log("new item", item)
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

import { catchLogAsync } from './helpers/try-catch-decorator'

class Hoge {
  @catchLogAsync
  async f() {}
}