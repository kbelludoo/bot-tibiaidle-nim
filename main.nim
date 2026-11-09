import std/[asyncdispatch, json, os, strutils]
import types, supervisor, dashboard, stealth

const DefaultAccountsExample = staticRead("accounts.example.json")

proc main() {.async.} =
  initStealth()

  echo "================================================================================"
  echo "       ⚡ TIBIA IDLE NATIVE NIM BOT (ZERO-GC & ALTA PERFORMANCE) ⚡"
  echo "================================================================================"

  let configPath = "accounts.json"
  var content = ""
  if fileExists(configPath):
    content = readFile(configPath)
  else:
    echo "Arquivo accounts.json não encontrado. Criando template padrão..."
    writeFile(configPath, DefaultAccountsExample)
    content = DefaultAccountsExample

  let node = parseJson(content)
  var activeConfigs: seq[AccountConfig] = @[]
  let targetAcc = getEnv("ACCOUNT", "")

  for item in node:
    let acc = parseAccountConfig(item)
    if not acc.enabled and acc.id != targetAcc:
      continue
    if targetAcc.len > 0 and acc.id != targetAcc:
      continue
    activeConfigs.add(acc)

  if activeConfigs.len == 0:
    echo "⚠️ Nenhuma conta com 'enabled: true' encontrada em accounts.json."
    echo "Edite accounts.json e habilite sua conta para iniciar o bot."

  let sup = newSupervisor(activeConfigs)
  await sup.startAll()

  let portStr = getEnv("PORT", "3001")
  let port = try: parseInt(portStr) except: 3001

  let server = newWebServer(sup, port)
  asyncCheck server.start()

  # Console Ticker periódico com jitter
  proc tickerLoop() {.async.} =
    var tick = 0
    while true:
      await jitterSleep(4000, 0.20)
      tick += 1
      var totalKills: int64 = 0
      var totalGold: int64 = 0
      var totalExp: int64 = 0
      for b in sup.bots:
        totalKills += b.kills
        totalGold += b.gold
        totalExp += b.exp

      echo "[Console Ticker #", tick, "] Contas: ", sup.bots.len, " | Kills: ", totalKills, " | Gold: ", totalGold, " | Exp: ", totalExp

  asyncCheck tickerLoop()

  # Mantém o loop principal rodando indefinidamente
  while true:
    await sleepAsync(60000)

waitFor main()
