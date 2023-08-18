import type { Serve } from "bun"

if (!isURL(process.env.IPFS_GATEWAY_HOST)) {
  throw new Error("IPFS_GATEWAY_HOST must be a valid URL")
}

export default {
  fetch: async (request, _server) => {
    try {
      const { searchParams, pathname } = new URL(request.url)

      const ipfsURL = `${process.env.IPFS_GATEWAY_HOST}/ipfs/${pathname}`
        + (searchParams.toString() ? `?${searchParams.toString()}` : "")

      return fetch(ipfsURL.toString())
    } catch (error) {
      console.log(
        `[./src/index.ts] ${error instanceof Error ? error.message : error}`,
        JSON.stringify(error, undefined, 2),
      )
      return new Response(`${error instanceof Error ? error.message : error}`, { status: 500 })
    }
  },
  error: (error) => {
    console.log(`[./src/index.ts] ${error.message}]`, JSON.stringify(error, undefined, 2))
    return new Response(`${error.message}`, { status: 500 })
  },
  port: process.env.PORT,
  development: process.env.NODE_ENV === "development",
} satisfies Serve

function isURL(url: string): boolean {
  try {
    new URL(url)
    return true
  } catch {
    return false
  }
}
