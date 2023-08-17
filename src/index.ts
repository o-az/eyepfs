import type { Serve } from "bun"

export default {
  port: process.env.PORT,
  development: process.env.NODE_ENV === "development",

  fetch: async (request, _server) => {
    const { searchParams, pathname } = new URL(request.url)

    const ipfsURL = new URL(
      `${process.env.IPFS_GATEWAY_HOST}/ipfs/${pathname}`
        + (searchParams.toString() ? `?${searchParams.toString()}` : ""),
    )

    return fetch(ipfsURL.toString(), {
      headers: {
        "user-agent": request.headers.get("user-agent") || "",
      },
    })
  },
  error: (error) => {
    console.log(`[./src/index.ts] ${error.message}]`, JSON.stringify(error, undefined, 2))
    return new Response(`${error.message}`, { status: 500 })
  },
} satisfies Serve
