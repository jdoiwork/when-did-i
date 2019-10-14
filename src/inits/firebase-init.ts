import * as firebase from "firebase/app"

const firebaseConfig = {
  apiKey: "AIzaSyCqgt50MoF52ZAzXE7EHr5kF7-HoFl5Ncs",
  authDomain: "when-did-i-29c17.firebaseapp.com",
  databaseURL: "https://when-did-i-29c17.firebaseio.com",
  projectId: "when-did-i-29c17",
  storageBucket: "when-did-i-29c17.appspot.com",
  messagingSenderId: "1038935939885",
  appId: "1:1038935939885:web:dc643a945366dc534b51a4",
  measurementId: "G-YSP0B2M5MB"
}

function init() {
  firebase.initializeApp(firebaseConfig)
  return firebase
}

export { init }
