
import { Elm } from './Main.elm'

const app = Elm.Main.init({
  //node: document.querySelector('main')
})

console.log("hello typescript")
console.log(app)

// dummy login
setTimeout(() => app.ports.loginStatusChanged.send("login"), 3000)
