import std/json

type
  GameCredentials* = object
    email*: string
    password*: string
    sessionCookie*: string
    ticket*: string
    worldId*: string

  GameSettings* = object
    huntTarget*: string
    huntId*: int
    lure*: int
    autoHunt*: bool
    autoSell*: bool
    autoBless*: bool
    autoDaily*: bool
    focusBestiary*: bool
    autoVip*: bool

  AccountConfig* = object
    id*: string
    name*: string
    enabled*: bool
    credentials*: GameCredentials
    settings*: GameSettings

  AccountInfo* = object
    id*: string
    name*: string
    accountId*: int
    worldId*: int

proc parseAccountConfig*(n: JsonNode): AccountConfig =
  result.id = n{"id"}.getStr("")
  result.name = n{"name"}.getStr(result.id)
  result.enabled = n{"enabled"}.getBool(true)

  if n.hasKey("credentials"):
    let c = n["credentials"]
    result.credentials.email = c{"email"}.getStr("")
    result.credentials.password = c{"password"}.getStr("")
    result.credentials.sessionCookie = c{"sessionCookie"}.getStr("")
    result.credentials.ticket = c{"ticket"}.getStr("")
    result.credentials.worldId = c{"worldId"}.getStr("1")
  else:
    result.credentials.email = n{"email"}.getStr("")
    result.credentials.password = n{"password"}.getStr("")
    result.credentials.sessionCookie = n{"sessionCookie"}.getStr("")
    result.credentials.ticket = n{"ticket"}.getStr("")
    result.credentials.worldId = n{"worldId"}.getStr("1")

  if n.hasKey("settings"):
    let s = n["settings"]
    result.settings.huntTarget = s{"hunt_target"}.getStr(s{"huntTarget"}.getStr(""))
    result.settings.huntId = s{"hunt_id"}.getInt(s{"huntId"}.getInt(26))
    result.settings.lure = s{"lure"}.getInt(2)
    result.settings.autoHunt = s{"auto_hunt"}.getBool(s{"autoHunt"}.getBool(true))
    result.settings.autoSell = s{"auto_sell"}.getBool(s{"autoSell"}.getBool(true))
    result.settings.autoBless = s{"auto_bless"}.getBool(s{"autoBless"}.getBool(true))
    result.settings.autoDaily = s{"auto_daily"}.getBool(s{"autoDaily"}.getBool(true))
    result.settings.focusBestiary = s{"focus_bestiary"}.getBool(s{"bestiaryMode"}.getBool(false))
    result.settings.autoVip = s{"auto_vip"}.getBool(s{"autoVip"}.getBool(true))
  else:
    result.settings.huntTarget = n{"huntName"}.getStr("")
    result.settings.huntId = n{"huntId"}.getInt(26)
    result.settings.lure = n{"lure"}.getInt(2)
    result.settings.autoHunt = n{"autoHunt"}.getBool(true)
    result.settings.autoSell = n{"autoSell"}.getBool(true)
    result.settings.autoBless = n{"autoBlessings"}.getBool(true)
    result.settings.autoDaily = n{"autoDaily"}.getBool(true)
    result.settings.focusBestiary = n{"bestiaryMode"}.getBool(false)
    result.settings.autoVip = n{"autoVip"}.getBool(true)
