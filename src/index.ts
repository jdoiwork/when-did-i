
import { Elm } from './Main.elm'

const app = Elm.Main.init({
  //node: document.querySelector('main')
})

console.log("hello typescript")
console.log(app)

// dummy login
setTimeout(() => app.ports.loginStatusChanged.send("logout"), 3000)

app.ports.loginWith.subscribe(provider => {
  console.log(`${provider} login`)
  app.ports.loginStatusChanged.send("login") 
})

app.ports.logout.subscribe(() => {
  console.log("logout")
  app.ports.loginStatusChanged.send("logout") 
})


window["app"] = app
