import { SerialPort } from "serialport"
import { ReadlineParser } from "@serialport/parser-readline"

export type Buzzer = {
  pressBuzzer: () => Promise<void>
  registerDoorbellHandler: (handler: () => Promise<"success" | "failure">) => void
}

type PortRef = {
  port: SerialPort
}

const pingPong = async (portRef: PortRef, parser: ReadlineParser, reconnectCallback: () => void) => {
  let gotPong = true

  setInterval(() => {
    if (!gotPong) {
      reconnectCallback()
    }
    gotPong = false
    portRef.port.write("ping\r\n")
  }, 1000)

  parser.on("data", (data) => {
    if (data === "pong") {
      gotPong = true
    }
  })
}

export const serialBuzzer = (serialPort: string): Buzzer => {
  let doorbellHandler: (() => Promise<"success" | "failure">) | null = null

  const parser = new ReadlineParser({ delimiter: "\r\n" })

  const setupPort = () => {
    const port = new SerialPort({
      path: serialPort,
      baudRate: 9600,
    })
    port.pipe(parser)

    port.on("error", (err) => {
      console.error("Serial port error: ", err)
    })

    return port
  }

  const portRef: PortRef = { port: setupPort() }

  pingPong(portRef, parser, () => {
    console.log("should reconnect")
    portRef.port.close()
    portRef.port = setupPort()
  })

  parser.on("data", (data) => {
    if (data === "ring") {
      doorbellHandler?.()
    } else if (data === "pong") {
      // ignore
    } else {
      console.log(`[buzzer] ${data}`)
    }
  })

  return {
    pressBuzzer: async () => {
      portRef.port.write("buzz\r\n")
    },
    registerDoorbellHandler: (handler) => {
      doorbellHandler = handler
    },
  }
}
