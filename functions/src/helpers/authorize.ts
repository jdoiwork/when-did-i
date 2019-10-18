import { CallableContext, HttpsError } from 'firebase-functions/lib/providers/https';

export function error401() : HttpsError {
  return new HttpsError("unauthenticated", "The request does not have valid authentication credentials for the operation.")
}

export function error403() : HttpsError {
  return new HttpsError("permission-denied", "The caller does not have permission to execute the specified operation.")
}


export async function authorize(context: CallableContext){
  return new Promise((resolve, reject) => {
    if(context.auth) {
      resolve(context.auth)
    } else {
      throw error401()
    }
  })
}
