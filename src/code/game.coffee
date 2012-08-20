TILE_SIZE = 32
MAP = [
  "################################"
  "#       #                      #"
  "#       #                      #"
  "#    @  #     #          ####  #"
  "#       #     #          #     #"
  "#       #     #    !     #%    #"
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
  speed: 128

class DumbMonster extends Monster
  color: Color.pulser(255, 0, 0, 0.5, 0.5)

class HunterMonster extends Monster
  color: Color.pulser(255, 0, 0, 1.0, 0.5)
  speed: 64
  size: TILE_SIZE * 0.5
  pathfinding: true

class Loot extends BoxEntity
  color: Color.pulser(220, 200, 0, 1.5)
  size: TILE_SIZE

class Player extends BoxEntity
  color: -> "blue"
  size: TILE_SIZE / 2

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
    # strong line from monster to collision point.
    line = new Line(monster.position, player.position)
    if (point = line.nearestIntersection(map.edges))
      line.to = point
      d.square(point, 8, Color.string(255, 0, 0, 0.2))
    d.line(line, strokeStyle: Color.string(255, 0, 0, 0.5))

  # Player!
  player.draw(d)



##
# Updating
updateEntities = (entities, timeDelta) ->
  player = entities.player

  # Monsters!
  _(entities.monsters).each (monster) ->
    line = new Line(monster.position, player.position)
    if monster.pathfinding?
      if _(monster.corners).any((p) -> line.nearestIntersection(map.edges))
        entities.hunterPath = _(new AStar().search(
          monster.position.toTile(TILE_SIZE),
          player.position.toTile(TILE_SIZE),
          map.walls,
          128
        )).map (point) -> point.fromTile(TILE_SIZE)
      else
        entities.hunterPath = []

      monster.moveTowards(entities.hunterPath[1] || player.position, monster.speed, timeDelta)
    else
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

    if player.moveTowards(entities.path[1] || nav.position, 256, timeDelta)
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

  entities.dumbMonsters = _(map.monsters).map (point) ->
    new DumbMonster(point.fromTile(TILE_SIZE))

  entities.hunters = _(map.hunters).map (point) ->
    new HunterMonster(point.fromTile(TILE_SIZE))

  entities.monsters = _.union(entities.dumbMonsters, entities.hunters)

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
