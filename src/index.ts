
import { Elm } from './Main.elm'

require("./inits/firebase-init").init()

const auth = require("./services/auth")

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
