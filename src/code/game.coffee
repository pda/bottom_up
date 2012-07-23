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

class Monster
  constructor: (@position) ->
  moveTowards: (other, distance = 1) ->
    difference = other.subtract(@position)
    if difference.length() > distance
      @position = @position.add(difference.normalized().multiply(distance))

@canvi = new Canvi(document, WIDTH, HEIGHT, "back", "main", "front")
canvi.build()

map = Map.fromAscii(TILE_SIZE, MAP)
map.draw(canvi.contexts["back"])

c = canvi.contexts["main"]
d = new DrawingTools(c)

monsters = _(map.monsters).map (point) ->
  new Monster(point.fromTile(TILE_SIZE))

# TODO: I AM NOT A MONSTER!
player = new Monster(map.player.fromTile(TILE_SIZE))

mousePoint = null
window.addEventListener "click", (event) ->
  mousePoint = Point.at(event.clientX, event.clientY)

lootColor = Color.pulser(220, 200, 0, 1)
drawObjects = ->
  c.clearRect(0, 0, WIDTH, HEIGHT)
  d.square(player.position, TILE_SIZE, "blue")
  _(monsters).each (monster) ->
    d.square(monster.position, TILE_SIZE, "red")
  _(map.loot).each (point) ->
    d.square(point.fromTile(TILE_SIZE), TILE_SIZE, lootColor())

updateObjects = ->
  _(monsters).each (m) ->
    m.moveTowards(player.position, 2)
  if mousePoint then player.moveTowards(mousePoint, 4)

tick = ->
  drawObjects()
  updateObjects()
  webkitRequestAnimationFrame(tick)

tick()
