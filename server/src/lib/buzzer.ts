import { SerialPort } from "serialport"
import { ReadlineParser } from "@serialport/parser-readline"

export type Buzzer = {
  pressBuzzer: () => Promise<void>
  registerDoorbellHandler: (handler: () => Promise<"success" | "failure">) => void
}

export const serialBuzzer = (serialPort: string): Buzzer => {
  let doorbellHandler: (() => Promise<"success" | "failure">) | null = null

  const port = new SerialPort({
    path: serialPort,
    baudRate: 9600,
  })

  const parser = port.pipe(new ReadlineParser({ delimiter: "\r\n" }))

  parser.on("data", (data) => {
    console.log(data)
    if (data === "ring") {
      doorbellHandler?.()
    }
  })

  port.on("error", (err) => {
    console.error("Serial port error: ", err)
  })

  return {
    pressBuzzer: async () => {
      port.write("buzz\r\n")
    },
    registerDoorbellHandler: (handler) => {
      doorbellHandler = handler
    },
  }
}
