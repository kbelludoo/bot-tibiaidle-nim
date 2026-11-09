type
  HuntRoute* = object
    id*: int
    routeStr*: string
    minLevel*: int
    maxLevel*: int
    baseExp*: float
    baseGold*: float

const TibiaHuntsCatalog*: array[11, HuntRoute] = [
  HuntRoute(id: 26, routeStr: "hunt-26", minLevel: 1, maxLevel: 20, baseExp: 120.0, baseGold: 60.0),
  HuntRoute(id: 30, routeStr: "hunt-30", minLevel: 20, maxLevel: 50, baseExp: 300.0, baseGold: 180.0),
  HuntRoute(id: 38, routeStr: "hunt-38", minLevel: 50, maxLevel: 80, baseExp: 800.0, baseGold: 450.0),
  HuntRoute(id: 46, routeStr: "hunt-46", minLevel: 80, maxLevel: 120, baseExp: 1900.0, baseGold: 1100.0),
  HuntRoute(id: 54, routeStr: "hunt-54", minLevel: 120, maxLevel: 170, baseExp: 4200.0, baseGold: 2400.0),
  HuntRoute(id: 66, routeStr: "hunt-66", minLevel: 170, maxLevel: 230, baseExp: 9500.0, baseGold: 5800.0),
  HuntRoute(id: 78, routeStr: "hunt-78", minLevel: 230, maxLevel: 310, baseExp: 21000.0, baseGold: 13000.0),
  HuntRoute(id: 90, routeStr: "hunt-90", minLevel: 310, maxLevel: 400, baseExp: 48000.0, baseGold: 30000.0),
  HuntRoute(id: 120, routeStr: "hunt-120", minLevel: 400, maxLevel: 600, baseExp: 110000.0, baseGold: 72000.0),
  HuntRoute(id: 160, routeStr: "hunt-160", minLevel: 600, maxLevel: 900, baseExp: 280000.0, baseGold: 180000.0),
  HuntRoute(id: 220, routeStr: "hunt-220", minLevel: 900, maxLevel: 1800, baseExp: 750000.0, baseGold: 480000.0),
]

proc selectBestHunt*(level: int): HuntRoute =
  for area in TibiaHuntsCatalog:
    if level >= area.minLevel and level <= area.maxLevel:
      return area
  result = TibiaHuntsCatalog[TibiaHuntsCatalog.high]
