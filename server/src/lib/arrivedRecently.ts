const getTime = () => new Date().getTime() / 1000

let lastArrival = 0

export const setArrivedNow = () => {
  lastArrival = getTime()
}

export const getArrivedRecently = (): boolean =>
  getTime() - lastArrival < 3 * 60
