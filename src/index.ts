// import bulma from 'bulma'
require('bulma')
import { Elm } from './Elm/Main.elm'
import * as auth from './services/auth'

require("./inits/firebase-init").init()

const app = Elm.Main.init({
  //node: document.querySelector('main')
})

console.log("hello typescript")
console.log(app)

app.ports.loginWith.subscribe(provider => {
  console.log(`${provider} login`)
  auth.signIn()
})

auth.subscribe((user) => {
  const status = user ? "login" : "logout"
  app.ports.loginStatusChanged.send(status)
})

app.ports.logout.subscribe(() => {
  console.log("logout")
  auth.signOut()
})


window["app"] = app
