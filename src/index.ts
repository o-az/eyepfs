import { isPossiblyCID, isURL } from './utilities.ts'

const IPFS_GATEWAY_HOST = Deno.env.get('IPFS_GATEWAY_HOST')
if (!IPFS_GATEWAY_HOST) throw new Error('IPFS_GATEWAY_HOST environment variable not set')

async function handler(request: Request) {
  const { pathname, search } = new URL(request.url)

  if (pathname.length === 0) return new Response('No path provided', { status: 400 })
  if (pathname === '/favicon.ico') return new Response('', { status: 418 })

  const pathParameters = pathname.split('/').filter(Boolean)
  // only `/ipfs/<cid>` or `/<cid>` allowed for pathname
  const cid = pathParameters.length === 2
    ? pathParameters.at(-1)
    : pathParameters.length === 1
    ? pathParameters.at(0)
    : undefined

  if (!isPossiblyCID(cid)) return new Response(`Invalid pathname: ${pathname}`, { status: 400 })

  const ipfsURL = `${IPFS_GATEWAY_HOST}/ipfs/${cid}` + search
  if (!isURL(ipfsURL)) return new Response(`Invalid IPFS URL: ${ipfsURL}`, { status: 400 })

  return fetch(ipfsURL)
}

Deno.serve(
  {
    port: Number(Deno.env.get('PORT')) || 3031,
    onError: (error) => {
      console.error(error)
      return new Response(error instanceof Error ? error.message : `Unknown error: ${error}`, {
        status: 500,
      })
    },
  },
  handler,
)
