import { FireStoreDatabase } from './firestore-db'

describe(FireStoreDatabase, () => {
  describe(FireStoreDatabase.changeEventFromDocumentChangeType, () => {
    const f = FireStoreDatabase.changeEventFromDocumentChangeType
    it("added → create", () => expect(f("added")).toBe("create"))
    it("removed → delete", () => expect(f("removed")).toBe("delete"))
    it("modified → update", () => expect(f("modified")).toBe("update"))
  })
})
