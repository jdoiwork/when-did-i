import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin'

let initFlag = false



export function init() {
  if(!initFlag) {
    admin.initializeApp(functions.config().firebase)
    initFlag = true;
  }
}