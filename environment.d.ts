interface EnvironmentVariables {
  readonly NODE_ENV: "development" | "production" | "test"
  readonly PORT: string
  readonly IPFS_GATEWAY_HOST: string
}

declare module "bun" {
  interface Env extends EnvironmentVariables {}
}
