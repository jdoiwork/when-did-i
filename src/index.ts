import './inits/css-init'
import * as auth from './services/auth'
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

app.postNewItem(text => {
  console.log(text)
})

window["app"] = app
