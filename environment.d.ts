interface EnvironmentVariables {
  readonly ENV: 'development' | 'production' | 'test'
  readonly PORT: string
  readonly IPFS_GATEWAY_HOST: string
}

declare namespace Deno {
  interface Env {
    get(key: keyof EnvironmentVariables): string | undefined
  }
}
