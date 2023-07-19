export const mergedPromises = <T = any>(): ((
  call: () => Promise<T>
) => Promise<T>) => {
  const current: { promise: Promise<T> | null } = { promise: null }

  return (callback) => {
    if (current.promise !== null) {
      return current.promise
    }

    current.promise = callback().then((result) => {
      current.promise = null
      return result
    })

    return current.promise
  }
}
