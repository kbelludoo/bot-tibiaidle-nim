import std/[asyncdispatch, asynchttpserver, json, strutils, times]
import supervisor, types, bot

type
  WebServer* = ref object
    supervisor*: Supervisor
    port*: int
    startedAt*: Time

proc newWebServer*(supervisor: Supervisor, port: int): WebServer =
  new(result)
  result.supervisor = supervisor
  result.port = port
  result.startedAt = getTime()

proc start*(self: WebServer) {.async.} =
  var server = newAsyncHttpServer()

  proc cb(req: Request) {.async.} =
    let elapsedSec = (getTime() - self.startedAt).inSeconds

    if req.url.path == "/api/status":
      var accArray = newJArray()
      for b in self.supervisor.bots:
        accArray.add(%*{
          "id": b.config.id,
          "name": b.config.name,
          "running": b.running,
          "kills": b.kills,
          "gold": b.gold,
          "exp": b.exp,
          "cb_state": "Closed",
          "fatigue": 0.0
        })

      let payload = %*{
        "game": "Tibia Idle",
        "engine": "Native Nim Ultra-Light (Zero-GC-Overhead)",
        "uptime_sec": elapsedSec,
        "total_accounts": self.supervisor.bots.len,
        "port": self.port,
        "accounts": accArray
      }

      let headers = newHttpHeaders([
        ("Content-Type", "application/json"),
        ("Access-Control-Allow-Origin", "*")
      ])
      await req.respond(Http200, $payload, headers)
    else:
      let headers = newHttpHeaders([("Content-Type", "text/plain")])
      await req.respond(Http404, "Not Found", headers)

  echo "🌐 [WebServer] Iniciando painel de status Tibia Idle na porta ", self.port
  await server.serve(Port(self.port), cb)
