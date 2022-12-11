import { sleep } from "../deps.ts"

export type Buzzer = {
  pressBuzzer: () => Promise<void>
}

export const liveBuzzer = (buzzerUrl: string): Buzzer => ({
  pressBuzzer: async () => {
    await fetch(buzzerUrl)
  },
})

export const dummyBuzzer = (): Buzzer => ({
  pressBuzzer: async () => {
    console.log("🚪 pressing buzzer")
    await sleep(0.5)
  },
})
