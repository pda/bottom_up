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

##
# Subclasses

class Monster extends BoxEntity
  color: -> "red"
  size: TILE_SIZE / 2

class Loot extends BoxEntity
  color: Color.pulser(220, 200, 0, 1)
  size: TILE_SIZE

class Player extends BoxEntity
  color: -> "blue"
  size: TILE_SIZE

class NaviationDestination extends BoxEntity
  color: -> Color.string(128, 128, 255, 0.25)
  size: TILE_SIZE

##
# "Misc"

@canvi = new Canvi(document, WIDTH, HEIGHT, "back", "main", "front")
canvi.build()

@map = Map.fromAscii(TILE_SIZE, MAP)
map.draw(canvi.contexts["back"])

d = new DrawingTools(canvi.contexts["main"])

monsters = _(map.monsters).map (point) ->
  new Monster(point.fromTile(TILE_SIZE))

loot = _(map.loot).map (point) ->
  new Loot(point.fromTile(TILE_SIZE))

@player = new Player(map.player.fromTile(TILE_SIZE))

navDestination = null
window.addEventListener "click", (event) ->
  navDestination = new NaviationDestination(Point.at(event.clientX, event.clientY))

##
# Colliding
wallCollisionDetection = (entity, timeDelta) ->
  _(entity.corners).each (corner) ->
    movement = new Line(corner, corner.add(entity.velocity.multiply(timeDelta)))
    if (wall = movement.nearestIntersectingLine(map.edges))
      #wallDelta = movement.intersection(wall).subtract(corner)
      if wall.isHorizontal()
        entity.velocity.y = 0
      else if wall.isVertical()
        entity.velocity.x = 0

##
# Drawing
drawObjects = ->
  d.c.clearRect(0, 0, WIDTH, HEIGHT)

  # Player!
  player.draw(d)

  # Monsters!
  _(monsters).each (monster) ->
    monster.draw(d)

    # faint red line from monster to player.
    line = new Line(monster.position, player.position)
    d.line(line, strokeStyle: Color.string(255, 0, 0, 0.05))

    # strong line from monster to collision point.
    if (point = line.nearestIntersection(map.edges))
      line.to = point
      d.square(point, 8, Color.string(255, 0, 0, 0.4))
    d.line(line, strokeStyle: Color.string(255, 0, 0, 0.5))

  # Loot!
  _(loot).each (loot) -> loot.draw(d)

  # Navigation destination!
  if navDestination
    navDestination.draw(d)
    line = new Line(player.position, navDestination.position)
    d.line(line, strokeStyle: Color.string(0, 0, 255, 0.2))
    if (point = line.nearestIntersection(map.edges))
      d.square(point, 8, Color.string(255, 0, 0, 0.4))
    _(map.edges).each (edge) ->
      if line.intersects(edge)
        intersection = line.intersection(edge)
        d.square(intersection, 8, Color.string(255, 0, 0, 0.2))

##
# Updating
updateObjects = (timeDelta) ->
  _(monsters).each (monster) ->
    line = new Line(monster.position, player.position)
    if _(map.edges).any((edge) -> line.intersects(edge))
      monster.stop()
    else
      monster.moveTowards(player.position, 128, timeDelta)
    wallCollisionDetection(monster)
    monster.update(timeDelta)
  if navDestination
    if player.moveTowards(navDestination.position, 256, timeDelta)
      navDestination = null
  wallCollisionDetection(player, timeDelta)
  player.update(timeDelta)

##
# Ticking
timeLast = (Date.now() / 1000) - (1 / 60)
tick = ->
  timeThis = Date.now() / 1000
  timeDelta = timeThis - timeLast
  timeLast = timeThis
  updateObjects(timeDelta)
  drawObjects()
  webkitRequestAnimationFrame(tick)

tick()
