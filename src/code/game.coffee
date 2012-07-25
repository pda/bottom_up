TILE_SIZE = 32
MAP = [
  "################################"
  "#       #                      #"
  "#       #               !      #"
  "#    @  #     #                #"
  "#       #     #                #"
  "#       #     #                #"
  "#  ######     #                #"
  "#             ########         #"
  "#             #  #             #"
  "#             #  #             #"
  "#         ########             #"
  "#                #     ######  #"
  "#                #     #       #"
  "#                #     #       #"
  "#                #     #  $    #"
  "#        !             #       #"
  "#                      #       #"
  "################################"
]

WIDTH_TILES = MAP[0].length
HEIGHT_TILES = MAP.length

WIDTH = TILE_SIZE * WIDTH_TILES
HEIGHT = TILE_SIZE * HEIGHT_TILES

class Entity
  constructor: (@position) ->
  # Move towards other point, return new distance remaining.
  moveTowards: (other, distance = 1) ->
    difference = other.subtract(@position)
    distance = Math.min(distance, difference.length())
    if distance > 0
      @moveTo(@position.add(difference.normalized().multiply(distance)))
    return distance
  moveTo: (position) ->
    @previousPosition = @position
    @position = position
  draw: (drawingTools) ->
    drawingTools.square(@position, @size, @color())

class Wall extends Entity
  size: TILE_SIZE

class Monster extends Entity
  color: -> "red"
  size: TILE_SIZE / 2

class Loot extends Entity
  color: Color.pulser(220, 200, 0, 1)
  size: TILE_SIZE

class Player extends Entity
  color: -> "blue"
  size: TILE_SIZE

class NaviationDestination extends Entity
  color: -> Color.string(128, 128, 255, 0.25)
  size: TILE_SIZE

@canvi = new Canvi(document, WIDTH, HEIGHT, "back", "main", "front")
canvi.build()

@map = Map.fromAscii(TILE_SIZE, MAP)
map.draw(canvi.contexts["back"])

d = new DrawingTools(canvi.contexts["main"])

monsters = _(map.monsters).map (point) ->
  new Monster(point.fromTile(TILE_SIZE))

loot = _(map.loot).map (point) ->
  new Loot(point.fromTile(TILE_SIZE))

player = new Player(map.player.fromTile(TILE_SIZE))

navDestination = null
window.addEventListener "click", (event) ->
  navDestination = new NaviationDestination(Point.at(event.clientX, event.clientY))

drawObjects = ->
  d.c.clearRect(0, 0, WIDTH, HEIGHT)
  player.draw(d)
  _(monsters).each (monster) -> monster.draw(d)
  _(loot).each (loot) -> loot.draw(d)
  if navDestination then navDestination.draw(d)

updateObjects = ->
  _(monsters).each (m) ->
    m.moveTowards(player.position, 2)
  if navDestination
    if player.moveTowards(navDestination.position, 4) == 0
      navDestination = null

tick = ->
  updateObjects()
  drawObjects()
  webkitRequestAnimationFrame(tick)

tick()
