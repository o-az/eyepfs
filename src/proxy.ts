import { isPossiblyCID, isURL } from "./utilities.ts"

// 32 bytes
if (!`${process.env.IPFS_GATEWAY_HOST}`.length) {
  throw new Error("IPFS_GATEWAY_HOST must be a valid URL")
}

export async function forwardRequest(event: { request: Request }) {
  const { pathname, search } = new URL(event.request.url)

  if (pathname.length === 0) return new Response("No path provided", { status: 400 })

  if (pathname === "/favicon.ico") return new Response("", { status: 418 })

  const pathParameters = pathname.split("/").filter(Boolean)
  // only `/ipfs/<cid>` or `/<cid>` allowed for pathname
  const cid = pathParameters.length === 2
    ? pathParameters.at(-1)
    : pathParameters.length === 1
    ? pathParameters.at(0)
    : undefined

  if (!isPossiblyCID(cid)) return new Response(`Invalid pathname: ${pathname}`, { status: 400 })

  const ipfsURL = `${process.env.IPFS_GATEWAY_HOST}/ipfs/${cid}` + search

  if (!isURL(ipfsURL)) return new Response(`Invalid IPFS URL: ${ipfsURL}`, { status: 400 })

  return fetch(ipfsURL)
}
