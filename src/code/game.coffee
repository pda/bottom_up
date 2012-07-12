TILE_SIZE = 20
MAP = [
  "################################"
  "#             #                #"
  "#             #                #"
  "#             #                #"
  "#         @   #         !      #"
  "#             #                #"
  "#             #                #"
  "#             #                #"
  "#    ##########                #"
  "#                              #"
  "#                              #"
  "#                              #"
  "#                              #"
  "#                              #"
  "#                              #"
  "#                ##########    #"
  "#                #             #"
  "#                #             #"
  "#        !       #             #"
  "#                #   $         #"
  "#                #             #"
  "#                #             #"
  "#                #             #"
  "################################"
]

WIDTH = TILE_SIZE * MAP[0].length
HEIGHT = TILE_SIZE * MAP.length


@canvi = new Canvi(document, WIDTH, HEIGHT, "back", "main", "front")
canvi.build()

map = Map.fromAscii(TILE_SIZE, MAP)
map.draw(canvi.contexts["back"])

c = canvi.contexts["main"]
d = new DrawingTools(c)

lootColor = Color.pulser(220, 200, 0, 1)
tick = ->
  c.clearRect(0, 0, WIDTH, HEIGHT)
  d.square(map.player.fromTile(TILE_SIZE), TILE_SIZE, "blue")
  _(map.monsters).each (point) ->
    d.square(point.fromTile(TILE_SIZE), TILE_SIZE, "red")
  _(map.loot).each (point) ->
    d.square(point.fromTile(TILE_SIZE), TILE_SIZE, lootColor())
  webkitRequestAnimationFrame(tick)

tick()
