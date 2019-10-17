import * as functions from 'firebase-functions';
import { CallableContext } from 'firebase-functions/lib/providers/https';

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
export const helloWorld = functions.https.onRequest((request, response) => {
 response.send("Hello from Firebase!");
});

export const helloFromWeb = functions.https.onCall((data:any, context: CallableContext) : any => {
  return {
    data, context
  }
})