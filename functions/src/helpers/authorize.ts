import { CallableContext, HttpsError } from 'firebase-functions/lib/providers/https';
import { auth } from 'firebase-admin';

// SEE: status document
// https://firebase.google.com/docs/reference/functions/providers_https_

export function error401() : HttpsError {
  return new HttpsError("unauthenticated", "The request does not have valid authentication credentials for the operation.")
}

export function error403() : HttpsError {
  return new HttpsError("permission-denied", "The caller does not have permission to execute the specified operation.")
}

type AuthInfo = { uid: string, token: auth.DecodedIdToken }

export async function authorize(context: CallableContext) : Promise<AuthInfo> {
  if(context.auth) {
    return context.auth
  } else {
    throw error401()
  }
}
