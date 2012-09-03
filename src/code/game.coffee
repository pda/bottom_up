TILE_SIZE = 32
MAP = [
  "################################"
  "#       #                      #"
  "#       #                      #"
  "#    @  #     #          ####  #"
  "#       #     #          #     #"
  "#       #     #    !     #     #"
  "#  ######     #          ####  #"
  "#             #                #"
  "#             #########        #"
  "#             #  #             #"
  "#             #  #             #"
  "#        #########    !        #"
  "#                #             #"
  "#  ####          #     ######  #"
  "#     #     !    #     #       #"
  "#     #          #     #       #"
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
  size: TILE_SIZE * 0.3
  speed: 64

class Loot extends BoxEntity
  color: Color.pulser(220, 200, 0, 1.5)
  size: TILE_SIZE

class Player extends BoxEntity
  color: -> "blue"
  size: TILE_SIZE / 2
  speed: 128

class NaviationDestination extends BoxEntity
  color: -> Color.string(128, 128, 255, 0.25)
  size: TILE_SIZE

##
# Drawing
drawEntities = (entities, drawingTools) ->
  player = entities.player
  d = drawingTools

  d.c.clearRect(0, 0, d.c.canvas.width, d.c.canvas.height)

  # Loot!
  _(entities.loot).each (loot) -> loot.draw(d)

  # Navigation destination!
  if (nav = entities.navDestination)
    nav.draw(d)
    color = Color.string(0, 0, 255, 0.2)
    line = new Line(player.position, nav.position)
    if entities.path.length
      _(entities.path).inject (memo, point) ->
        if memo then d.line(new Line(memo, point), strokeStyle: color)
        point
    else
      d.line(line, strokeStyle: color)

  # Monsters!
  _.chain(entities.monsters).each (monster) ->
    monster.draw(d)

  # Player!
  player.draw(d)



##
# Updating
updateEntities = (entities, timeDelta) ->
  player = entities.player

  # Monsters!
  _(entities.monsters).each (monster) ->
    line = new Line(monster.position, player.position)
    monster.moveTowards(player.position, monster.speed, timeDelta)
    monster.collider.withLines(map.edges, timeDelta)
    monster.update(timeDelta)

  # Player!
  if (nav = entities.navDestination)

    entities.path ||= []
    if !entities.playerTile || !entities.playerTile.isEqual(player.position.toTile(TILE_SIZE))

      entities.playerTile = player.position.toTile(TILE_SIZE)

      if _(player.corners).any((p) -> new Line(p, nav.position).nearestIntersection(map.edges))
        entities.path = _(new AStar().search(
          player.position.toTile(TILE_SIZE),
          nav.position.toTile(TILE_SIZE),
          map.walls,
          128
        )).map (point) -> point.fromTile(TILE_SIZE)
      else
        entities.path = []

    if player.moveTowards(entities.path[1] || nav.position, player.speed, timeDelta)
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

  entities.hunters = _(map.hunters).map (point) ->
    new HunterMonster(point.fromTile(TILE_SIZE))

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
    requestAnimationFrame(tick)

  tick()
)()
