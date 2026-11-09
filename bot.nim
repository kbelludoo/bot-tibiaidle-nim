import std/[asyncdispatch, strutils, times]
import types, catalog, session, socket, stealth

type
  BotInstance* = ref object
    config*: AccountConfig
    sessionClient*: SessionClient
    socket*: TibiaIdleSocket
    accountInfo*: AccountInfo
    kills*: int64
    gold*: int64
    exp*: int64
    currentLevel*: int
    bestiaryKills*: int64
    running*: bool
    status*: string

proc newBotInstance*(config: AccountConfig): BotInstance =
  new(result)
  result.config = config
  result.sessionClient = newSessionClient()
  result.socket = nil
  result.kills = 0
  result.gold = 0
  result.exp = 0
  result.currentLevel = 20
  result.bestiaryKills = 0
  result.running = false
  result.status = "Iniciando"

proc runLoop*(self: BotInstance) {.async.} =
  self.running = true
  echo "🚀 Bot [", self.config.name, "] (Tibia Idle Nim) iniciado com WebSocket e Sessão ativos."

  let cookie = self.config.credentials.sessionCookie
  var ticket = self.config.credentials.ticket

  # 1. Validar Sessao se cookie estiver configurado
  if cookie.len > 0 and cookie != "seu-token-de-sessao-ou-jwt":
    try:
      self.accountInfo = await self.sessionClient.validateSession(cookie)
      echo "🛡️ Sessão ativa no Tibia Idle: [", self.accountInfo.name, "] AccountID: ", self.accountInfo.accountId, ", World: ", self.accountInfo.worldId

      if ticket.len == 0:
        let worldId = if self.config.credentials.worldId.len > 0: self.config.credentials.worldId else: "1"
        try:
          ticket = await self.sessionClient.getWorldTicket(cookie, worldId)
        except CatchableError as e:
          echo "⚠️ Erro ao obter world-ticket: ", e.msg
    except CatchableError as e:
      echo "⚠️ Validação de sessão /auth/me: ", e.msg

  # 2. Conectar WebSocket se ticket disponivel
  if ticket.len > 0:
    let wsUrl = "wss://play.tibidle.com/ws?ticket=" & ticket
    self.socket = await connectTibiaSocket(wsUrl, ticket)

  var loopCounter = 0
  var lastDailyClaim = getTime() - initDuration(days = 1)

  while self.running:
    loopCounter += 1

    # Recompensa diária (com jitter e pacing)
    if self.config.settings.autoDaily and (getTime() - lastDailyClaim).inHours >= 12:
      lastDailyClaim = getTime()
      if self.socket != nil and self.socket.isConnected:
        discard await self.socket.claimDaily()
        await pacingStep()
      echo "[", self.config.name, "] Recompensa diária resgatada com sucesso."

    # Ciclo de Caça no Tibia Idle
    if self.config.settings.autoHunt:
      let hunt = selectBestHunt(self.currentLevel)

      # Iniciar / renovar rota a cada 20 ticks (~30s)
      if loopCounter mod 20 == 1:
        if self.socket != nil and self.socket.isConnected:
          discard await self.socket.startHunt(hunt.id)
        echo "🏹 [", self.config.name, "] Caçando na área [", hunt.routeStr, "] (Hunt #", hunt.id, ") com Lure=", self.config.settings.lure

      # Venda de lixo no NPC a cada 40 ticks (~60s)
      if self.config.settings.autoSell and loopCounter mod 40 == 0:
        if self.socket != nil and self.socket.isConnected:
          discard await self.socket.sellTrash()
        echo "💰 [", self.config.name, "] Venda automática de drops no NPC executada."

      # Bênçãos a cada 60 ticks (~90s)
      if self.config.settings.autoBless and loopCounter mod 60 == 0:
        if self.socket != nil and self.socket.isConnected:
          for b in 1 .. 5:
            discard await self.socket.buyBlessing(b)
            await pacingStep()

      self.kills += 1
      self.gold += int64(hunt.baseGold)
      self.exp += int64(hunt.baseExp)

      if self.config.settings.focusBestiary:
        self.bestiaryKills += 1

    # Intervalo de caça orgânico com jitter (1.2s - 1.8s) para anti-detecção
    await jitterSleep(1500, 0.20)

  echo "🛑 Bot [", self.config.name, "] finalizado."
