const TryCatchDecorator = (target, name, descriptor) => {
  const fn = descriptor.value
  descriptor.value = async function(...args) {
    try {
      return await fn.apply(this, args)
    } catch (error) {
      console.error(error)
      return error;
    }
  }
}

export { TryCatchDecorator }
