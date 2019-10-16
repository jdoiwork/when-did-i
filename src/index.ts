import './inits/css-init'
import * as auth from './services/auth'
import * as db from './services/dummy-database'

import { ElmAppAdapter } from './helpers/elm-app-adapter'

require("./inits/firebase-init").init()

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
