export function isURL(url: string): boolean {
  try {
    new URL(url)
    return true
  } catch {
    return false
  }
}


// simple checks to rule out _some_ invalid CIDs
export function isPossiblyCID(possibleCID?: string) {
  const cidRegex =
    /Qm[1-9A-HJ-NP-Za-km-z]{44,}|b[A-Za-z2-7]{58,}|B[A-Z2-7]{58,}|z[1-9A-HJ-NP-Za-km-z]{48,}|F[0-9A-F]{50,}/
  if (!possibleCID) return false
  return cidRegex.test(possibleCID)
}
