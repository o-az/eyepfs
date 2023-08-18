import type { Serve } from "bun"
import { forwardRequest } from './proxy.ts'

export default {
  fetch: async (request, _server) => forwardRequest({ request }),
  // any thrown errors will be caught and passed to `error` here
  error: (error) => {
    console.error(error)
    return new Response(`${error.code} - ${error.message}`, { status: 500 })
  },
  port: process.env.PORT,
  development: process.env.NODE_ENV === "development",
} satisfies Serve
