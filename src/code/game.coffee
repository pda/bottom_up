TILE_SIZE = 32
MAP = [
  "################################"
  "#       #                      #"
  "#       #                      #"
  "#    @  #     #          ####  #"
  "#       #     #          ####  #"
  "#       #     #   !      ####  #"
  "#  ######     #          ####  #"
  "#             ########         #"
  "#             #  #             #"
  "#             #  #   !         #"
  "#         ########             #"
  "#  ####          #     ######  #"
  "#  ####      !   #     #       #"
  "#  ####          #     #       #"
  "#  ####          #     #  $    #"
  "#                      #       #"
  "#                      #       #"
  "################################"
]

WIDTH_TILES = MAP[0].length
HEIGHT_TILES = MAP.length

WIDTH = TILE_SIZE * WIDTH_TILES
HEIGHT = TILE_SIZE * HEIGHT_TILES

class Entity
  constructor: (@position) ->
    @halfSize = @size / 2
    @sizeDelta = Point.at(@halfSize, @halfSize)
    @velocity = Point.zero()
  # Move towards other point, return new distance remaining.
  moveTowards: (other, distance = 1) ->
    difference = other.subtract(@position)
    distance = Math.min(distance, difference.length())
    if distance > 0
      @velocity = difference.normalized().multiply(distance)
    else
      @stop()
    return distance
  stop: ->
    @velocity = Point.zero()
  update: ->
    @moveTo(@position.add(@velocity))
  setPosition: (position) ->
    @position = position
    @top = position.subtract(@sizeDelta).y
    @bottom = position.add(@sizeDelta).y
    @left = position.subtract(@sizeDelta).x
    @right = position.add(@sizeDelta).x
  moveTo: (position) ->
    @previousPosition = @position
    @setPosition(position)
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

wallCollisionDetection = (entity) ->
  _(map.edges).each (edge) ->
    if edge.isHorizontal()
      if (entity.right > edge.from.x && entity.left < edge.to.x)
        if entity.bottom > edge.from.y && entity.top < edge.to.y
          if entity.position.y < edge.from.y # above
            y = edge.from.y - entity.halfSize
          else # below
            y = edge.from.y + entity.halfSize
          entity.setPosition(Point.at(entity.position.x, y))
    else if edge.isVertical()
      if (entity.bottom > edge.from.y && entity.top < edge.to.y)
        if entity.right > edge.from.x && entity.left < edge.to.x
          if entity.position.x < edge.from.x # left
            x = edge.from.x - entity.halfSize
          else # right
            x = edge.from.x + entity.halfSize
          entity.setPosition(Point.at(x, entity.position.y))


navDestination = null
window.addEventListener "click", (event) ->
  navDestination = new NaviationDestination(Point.at(event.clientX, event.clientY))

drawObjects = ->
  d.c.clearRect(0, 0, WIDTH, HEIGHT)
  player.draw(d)
  _(monsters).each (monster) ->
    monster.draw(d)
    d.c.strokeStyle = Color.string(255, 0, 0, 0.2)
    line = new Line(monster.position, player.position)
    d.line(line.from, line.to)
    _(map.edges).each (edge) ->
      if line.intersects(edge)
        intersection = line.intersection(edge)
        d.square(intersection, 8, Color.string(255, 0, 0, 0.2))
  _(loot).each (loot) -> loot.draw(d)
  if navDestination
    navDestination.draw(d)
    d.c.strokeStyle = Color.string(0, 0, 255, 0.2)
    line = new Line(player.position, navDestination.position)
    d.line(line.from, line.to)
    _(map.edges).each (edge) ->
      if line.intersects(edge)
        intersection = line.intersection(edge)
        d.square(intersection, 8, Color.string(255, 0, 0, 0.2))

updateObjects = ->
  _(monsters).each (monster) ->
    line = new Line(monster.position, player.position)
    if _(map.edges).any((edge) -> line.intersects(edge))
      monster.stop()
    else
      monster.moveTowards(player.position, 2)
    wallCollisionDetection(monster)
    monster.update()
  if navDestination
    if player.moveTowards(navDestination.position, 4) == 0
      navDestination = null
  player.update()
  wallCollisionDetection(player)

tick = ->
  updateObjects()
  drawObjects()
  webkitRequestAnimationFrame(tick)

tick()
