import std/[asyncdispatch, random]

proc initStealth*() =
  randomize()

proc jitterDelay*(baseMs: int, variancePct: float = 0.20): int =
  let minF = 1.0 - variancePct
  let maxF = 1.0 + variancePct
  let factor = minF + rand(maxF - minF)
  result = max(1, int(float(baseMs) * factor))

proc jitterSleep*(baseMs: int, variancePct: float = 0.20) {.async.} =
  let delay = jitterDelay(baseMs, variancePct)
  await sleepAsync(delay)

proc pacingStep*() {.async.} =
  let delay = 300 + rand(300) # 300ms a 600ms
  await sleepAsync(delay)
