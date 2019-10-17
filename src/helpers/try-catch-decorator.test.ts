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

describe("@catchLogAsync", () => {
  let spy : jest.SpyInstance = null
  beforeEach(() => {
    spy = jest.spyOn(console, 'error');
  })
  afterEach(() => {
    spy.mockRestore()
  })

  test("rethrow when throw error", () =>{
    expect.assertions(2)
    return new Hoge().f().catch((error: Error) => {
      expect(spy).toHaveBeenCalled()
      expect(error.message).toMatch(HogeErrorMessage)
    })
  })

  test("promise then", () =>{
    return new Hoge().g().then(n => expect(n).toBe(true))
  })
  
    
})
