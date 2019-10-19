import { IDataBaseService } from './database/types'

import { FireStoreDatabase, isFirebaseUser } from './database/firestore-db'
import { NullDatabase } from './database/null-db'

export type DatabaseType = "null" | "firestore"

export function createService(user?: any) : IDataBaseService {
  if (isFirebaseUser(user)) {
    return new FireStoreDatabase(user)
  } else {
    return new NullDatabase()
  }
}

