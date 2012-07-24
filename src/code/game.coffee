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
  avoid: (other) ->
    if @isOverlapping(other)
      @position = @previousPosition
  isOverlapping: (other) ->
    combinedHalfSize = @size / 2 + other.size / 2
    Math.abs(@position.x - other.position.x) < combinedHalfSize &&
      Math.abs(@position.y - other.position.y) < combinedHalfSize
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

c = canvi.contexts["main"]
d = new DrawingTools(c)

@wallKeys = {}
_(map.walls).each (point) ->
  wallKeys[point.toString()] = true

# TODO: refactor this, obviously.
@wallFaces = []
halfTile = TILE_SIZE / 2
_(map.walls).each (tilePoint) ->
  screenPoint = tilePoint.fromTile(TILE_SIZE)
  unless wallKeys[tilePoint.add(Point.at(0, -1))] || tilePoint.y == 0 # above
    wallFaces.push(new Line(
      Point.at(screenPoint.x - halfTile, screenPoint.y - halfTile)
      Point.at(screenPoint.x + halfTile, screenPoint.y - halfTile)
    ))
  unless wallKeys[tilePoint.add(Point.at(1, 0))] || tilePoint.x == WIDTH_TILES - 1 # right
    wallFaces.push(new Line(
      Point.at(screenPoint.x + halfTile, screenPoint.y - halfTile)
      Point.at(screenPoint.x + halfTile, screenPoint.y + halfTile)
    ))
  unless wallKeys[tilePoint.add(Point.at(0, 1))] || tilePoint.y == HEIGHT_TILES - 1 # below
    wallFaces.push(new Line(
      Point.at(screenPoint.x - halfTile, screenPoint.y + halfTile)
      Point.at(screenPoint.x + halfTile, screenPoint.y + halfTile)
    ))
  unless wallKeys[tilePoint.add(Point.at(-1, 0))] || tilePoint.x == 0 # left
    wallFaces.push(new Line(
      Point.at(screenPoint.x - halfTile, screenPoint.y - halfTile)
      Point.at(screenPoint.x - halfTile, screenPoint.y + halfTile)
    ))

wallFacesMerged = []
wallFacesDiscarded = {}
_(wallFaces).each (line) ->
  if wallFacesDiscarded[line.toString()] then return
  _(wallFaces).each (otherLine) ->
    if line.isContinuation(otherLine)
      wallFacesDiscarded[otherLine.toString()] = true
      line = line.merge(otherLine)
  wallFacesMerged.push(line)

_(wallFacesMerged).each (line) ->
  _(new DrawingTools(canvi.contexts["back"])).tap (d) ->
    d.c.lineWidth = 4
    d.c.strokeStyle = Color.gray(0.6)
    d.line(line.toArray()...)
    _(line.toArray()).each (p) -> d.square(p, 6, Color.gray(0.6))

monsters = _(map.monsters).map (point) ->
  new Monster(point.fromTile(TILE_SIZE))

loot = _(map.loot).map (point) ->
  new Loot(point.fromTile(TILE_SIZE))

player = new Player(map.player.fromTile(TILE_SIZE))

navDestination = null
window.addEventListener "click", (event) ->
  navDestination = new NaviationDestination(Point.at(event.clientX, event.clientY))

drawObjects = ->
  c.clearRect(0, 0, WIDTH, HEIGHT)
  player.draw(d)
  _(monsters).each (monster) -> monster.draw(d)
  _(loot).each (loot) -> loot.draw(d)
  if navDestination then navDestination.draw(d)

checkCollisions = ->


updateObjects = ->
  _(monsters).each (m) ->
    m.moveTowards(player.position, 2)
  if navDestination
    if player.moveTowards(navDestination.position, 4) == 0
      navDestination = null
  checkCollisions()

tick = ->
  updateObjects()
  drawObjects()
  webkitRequestAnimationFrame(tick)

tick()
