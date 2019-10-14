
var firebase = require("firebase/app")

require("firebase/auth")

const providers = {
  google: new firebase.auth.GoogleAuthProvider(),
}


function logError(error) {
    // // Handle Errors here.
    // var errorCode = error.code;
    // var errorMessage = error.message;
    // // The email of the user's account used.
    // var email = error.email;
    // // The firebase.auth.AuthCredential type that was used.
    // var credential = error.credential;
    // // ...
    console.error("error", error)
}

async function signIn() {
    try {
        const result = await firebase.auth().signInWithPopup(providers.google)
        // This gives you a Google Access Token. You can use it to access the Google API.
        // let token = result.credential.accessToken;
        // // The signed-in user info.
        // let user = result.user;
        // // ...
        // console.debug("OK", token, user)
        console.debug(result)

    }
    catch (error) {
        logError(error)
    }
}

function subscribe(callback) {
    firebase.auth().onAuthStateChanged(function(user) {
        if (user) {
          // User is signed in.
          console.log("user is signed in", user)
        }
        else {
          console.log("user is signed out")
        }
        
        callback(user)
    })
}


export { signIn, subscribe }
