import { catchLogAsync } from './try-catch-decorator'


const HogeErrorMessage = "aaaa"
class Hoge {
  @catchLogAsync
  async f(): Promise<string>  {
    throw new Error(HogeErrorMessage)
  }

  async g(): Promise<boolean>  {
    return true
  }
}

test("rethrow when throw error", () =>{
  expect.assertions(1)
  return new Hoge().f().catch((error: Error) => expect(error.message).toMatch(HogeErrorMessage))
})

test("promise then", () =>{
  return new Hoge().g().then(n => expect(n).toBe(true))
})

