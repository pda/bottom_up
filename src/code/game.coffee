TILE_SIZE = 32
MAP = [
  "################################"
  "#       #                      #"
  "#       #               !      #"
  "#    @  #      #               #"
  "#       #      #               #"
  "#       #      #               #"
  "#  ######      #               #"
  "#              #               #"
  "#              #######         #"
  "#         #######              #"
  "#               #              #"
  "#               #      ######  #"
  "#               #      #       #"
  "#               #      #       #"
  "#               #      #  $    #"
  "#        !             #       #"
  "#                      #       #"
  "################################"
]

WIDTH = TILE_SIZE * MAP[0].length
HEIGHT = TILE_SIZE * MAP.length

class Entity
  constructor: (@position) ->
  moveTowards: (other, distance = 1) ->
    difference = other.subtract(@position)
    if difference.length() > distance
      @position = @position.add(difference.normalized().multiply(distance))
  draw: (drawingTools) ->
    drawingTools.square(@position, @size, @color())

class Monster extends Entity
  color: -> "red"
  size: TILE_SIZE / 2

class Loot extends Entity
  color: Color.pulser(220, 200, 0, 1)
  size: TILE_SIZE

class Player extends Entity
  color: -> "blue"
  size: TILE_SIZE / 2

@canvi = new Canvi(document, WIDTH, HEIGHT, "back", "main", "front")
canvi.build()

map = Map.fromAscii(TILE_SIZE, MAP)
map.draw(canvi.contexts["back"])

c = canvi.contexts["main"]
d = new DrawingTools(c)

monsters = _(map.monsters).map (point) ->
  new Monster(point.fromTile(TILE_SIZE))

loot = _(map.loot).map (point) ->
  new Loot(point.fromTile(TILE_SIZE))

player = new Player(map.player.fromTile(TILE_SIZE))

mousePoint = null
window.addEventListener "click", (event) ->
  mousePoint = Point.at(event.clientX, event.clientY)

drawObjects = ->
  c.clearRect(0, 0, WIDTH, HEIGHT)
  player.draw(d)
  _(monsters).each (monster) -> monster.draw(d)
  _(loot).each (loot) -> loot.draw(d)

updateObjects = ->
  _(monsters).each (m) ->
    m.moveTowards(player.position, 2)
  if mousePoint then player.moveTowards(mousePoint, 4)

tick = ->
  updateObjects()
  drawObjects()
  webkitRequestAnimationFrame(tick)

tick()
