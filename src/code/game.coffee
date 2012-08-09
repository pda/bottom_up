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
# Drawing
drawEntities = (entities, drawingTools) ->
  player = entities.player
  d = drawingTools

  d.c.clearRect(0, 0, d.c.canvas.width, d.c.canvas.height)

  # Player!
  player.draw(d)

  # Monsters!
  _(entities.monsters).each (monster) ->
    monster.draw(d)
    # strong line from monster to collision point.
    line = new Line(monster.position, player.position)
    if (point = line.nearestIntersection(map.edges))
      line.to = point
      d.square(point, 8, Color.string(255, 0, 0, 0.2))
    d.line(line, strokeStyle: Color.string(255, 0, 0, 0.5))

  # Loot!
  _(entities.loot).each (loot) -> loot.draw(d)

  # Navigation destination!
  if (nav = entities.navDestination)
    nav.draw(d)
    line = new Line(player.position, nav.position)
    d.line(line, strokeStyle: Color.string(0, 0, 255, 0.2))
    if (point = line.nearestIntersection(map.edges))
      d.square(point, 8, Color.string(255, 0, 0, 0.4))
    _(map.edges).each (edge) ->
      if line.intersects(edge)
        intersection = line.intersection(edge)
        d.square(intersection, 8, Color.string(255, 0, 0, 0.2))

##
# Updating
updateEntities = (entities, timeDelta) ->
  player = entities.player

  # Monsters!
  _(entities.monsters).each (monster) ->
    line = new Line(monster.position, player.position)
    monster.moveTowards(player.position, 128, timeDelta)
    monster.collider.withLines(map.edges, timeDelta)
    monster.update(timeDelta)

  # Player!
  if (nav = entities.navDestination)
    if player.moveTowards(nav.position, 256, timeDelta)
      entities.navDestination = null
  player.collider.withLines(map.edges, timeDelta)
  player.update(timeDelta)

##
# Bootstrap
(->
  @canvi = new Canvi(document, WIDTH, HEIGHT, "back", "main", "front")
  canvi.build()

  @map = Map.fromAscii(TILE_SIZE, MAP)
  map.draw(canvi.contexts["back"])

  drawingTools = new DrawingTools(canvi.contexts["main"])

  entities = {}

  entities.monsters = _(map.monsters).map (point) ->
    new Monster(point.fromTile(TILE_SIZE))

  entities.loot = _(map.loot).map (point) ->
    new Loot(point.fromTile(TILE_SIZE))

  entities.player = new Player(map.player.fromTile(TILE_SIZE))

  window.addEventListener "click", (event) ->
    entities.navDestination = new NaviationDestination(Point.at(event.clientX, event.clientY))

  ##
  # Ticking
  timeLast = (Date.now() / 1000) - (1 / 60)
  tick = ->
    timeThis = Date.now() / 1000
    timeDelta = timeThis - timeLast
    timeLast = timeThis
    updateEntities(entities, timeDelta)
    drawEntities(entities, drawingTools)
    webkitRequestAnimationFrame(tick)

  tick()
)()
