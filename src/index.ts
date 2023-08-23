import { isPossiblyCID, isURL } from './utilities.ts'

const IPFS_GATEWAY_HOST = Deno.env.get('IPFS_GATEWAY_HOST')
if (!IPFS_GATEWAY_HOST) throw new Error('IPFS_GATEWAY_HOST environment variable not set')

async function handler(request: Request, info: Deno.ServeHandlerInfo): Promise<Response> {
  const headers = new Headers(request.headers)
  headers.set('Access-Control-Allow-Methods', 'GET, OPTIONS, HEAD')
  headers.set('Access-Control-Allow-Headers', 'Content-Type')
  
  const { hostname: identifier } = info.remoteAddr ?? 'anonymous'

  const origin = headers.get('Origin')
  const allowedOrigins = Deno.env.get('ALLOWED_ORIGINS')?.split(',') ?? []

  if (!allowedOrigins.includes(identifier)) {
    return new Response(`Origin ${origin} not allowed`, { status: 403, headers })
  }

  if (request.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers })
  }
  const { pathname, search } = new URL(request.url)

  if (pathname.length === 0) {
    return new Response('No path provided', { status: 400, headers })
  }
  if (pathname === '/favicon.ico') return new Response('', { status: 418, headers })

  const pathParameters = pathname.split('/').filter(Boolean)
  // only `/ipfs/<cid>` or `/<cid>` allowed for pathname
  const cid = pathParameters.length === 2
    ? pathParameters.at(-1)
    : pathParameters.length === 1
    ? pathParameters.at(0)
    : undefined

  if (!isPossiblyCID(cid)) {
    return new Response(`Invalid pathname: ${pathname}`, { status: 400, headers })
  }

  const ipfsURL = `${IPFS_GATEWAY_HOST}/ipfs/${cid}` + search
  if (!isURL(ipfsURL)) {
    return new Response(`Invalid IPFS URL: ${ipfsURL}`, { status: 400, headers })
  }

  return fetch(ipfsURL, { headers })
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
