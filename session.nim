import std/[asyncdispatch, httpclient, json, strutils]
import types

type
  SessionClient* = ref object
    baseUrl*: string

const
  DefaultBaseUrl* = "https://play.tibidle.com"
  UserAgentStr* = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

proc newSessionClient*(baseUrl: string = DefaultBaseUrl): SessionClient =
  new(result)
  result.baseUrl = if baseUrl.len > 0: baseUrl.strip(chars = {'/'}) else: DefaultBaseUrl

proc createHeaders(cookie: string, originUrl: string): HttpHeaders =
  result = newHttpHeaders([
    ("User-Agent", UserAgentStr),
    ("Origin", originUrl),
    ("Referer", originUrl & "/"),
    ("Content-Type", "application/json")
  ])
  if cookie.len > 0:
    result.add("Cookie", cookie)

proc validateSession*(self: SessionClient, cookie: string): Future[AccountInfo] {.async.} =
  let client = newAsyncHttpClient()
  client.headers = createHeaders(cookie, self.baseUrl)
  defer: client.close()

  let url = self.baseUrl & "/auth/me"
  let resp = await client.get(url)
  if resp.code == Http200:
    let body = await resp.body
    let node = parseJson(body)
    result.id = node{"id"}.getStr("")
    result.name = node{"name"}.getStr("")
    result.accountId = node{"account_id"}.getInt(node{"accountId"}.getInt(0))
    result.worldId = node{"world_id"}.getInt(node{"worldId"}.getInt(1))
  else:
    raise newException(IOError, "Sessão inválida HTTP: " & $resp.code)

proc getWorldTicket*(self: SessionClient, cookie: string, worldId: string): Future[string] {.async.} =
  let client = newAsyncHttpClient()
  client.headers = createHeaders(cookie, self.baseUrl)
  defer: client.close()

  let url = self.baseUrl & "/auth/world-ticket"
  let body = $(%*{"worldId": worldId})
  let resp = await client.post(url, body)
  if resp.code == Http200:
    let respText = await resp.body
    let node = parseJson(respText)
    result = node{"ticket"}.getStr("")
  else:
    raise newException(IOError, "Falha ao obter world-ticket: " & $resp.code)
