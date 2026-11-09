import std/[asyncdispatch, json, strutils]
import ws

type
  TibiaIdleSocket* = ref object
    ws*: WebSocket
    isConnected*: bool

proc connectTibiaSocket*(wsUrl: string, ticket: string): Future[TibiaIdleSocket] {.async.} =
  new(result)
  result.isConnected = false
  try:
    echo "[TibiaIdle WS] Conectando a ", wsUrl
    let socket = await newWebSocket(wsUrl)
    result.ws = socket
    result.isConnected = true

    # Envia payload de autenticacao
    let authMsg = %*{
      "type": "auth",
      "data": {
        "ticket": ticket,
        "tradeFlowVersion": 2
      }
    }
    await socket.send($authMsg)
    echo "[TibiaIdle WS] Autenticação enviada com sucesso"
  except CatchableError as e:
    echo "[TibiaIdle WS] Erro ao conectar: ", e.msg
    result.isConnected = false

proc sendMessage*(self: TibiaIdleSocket, msgType: string, data: JsonNode): Future[bool] {.async.} =
  if self == nil or not self.isConnected:
    return false
  try:
    let payload = %*{
      "type": msgType,
      "data": data
    }
    await self.ws.send($payload)
    result = true
  except CatchableError as e:
    echo "[TibiaIdle WS] Erro ao enviar mensagem: ", e.msg
    self.isConnected = false
    result = false

proc startHunt*(self: TibiaIdleSocket, huntId: int): Future[bool] {.async.} =
  result = await self.sendMessage("start_hunt", %*{"huntId": huntId})

proc stopHunt*(self: TibiaIdleSocket): Future[bool] {.async.} =
  result = await self.sendMessage("stop_hunt", newJObject())

proc sellTrash*(self: TibiaIdleSocket): Future[bool] {.async.} =
  result = await self.sendMessage("sell_trash", newJObject())

proc buyBlessing*(self: TibiaIdleSocket, blessingId: int): Future[bool] {.async.} =
  result = await self.sendMessage("buy_blessing", %*{"blessingId": blessingId})

proc claimDaily*(self: TibiaIdleSocket): Future[bool] {.async.} =
  result = await self.sendMessage("claim_daily", newJObject())
