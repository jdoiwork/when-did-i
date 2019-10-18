import { IDataBaseService } from './database/types'

import { FireStoreDatabase } from './database/firestore-db'
import { NullDatabase } from './database/null-db'

type DatabaseType = "null" | "firestore"

export function createService(type?: DatabaseType) : IDataBaseService {
  if (type === "firestore") {
    return new FireStoreDatabase()
  } else {
    return new NullDatabase()
  }
}

