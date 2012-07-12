class @Map

  constructor: (@player, @walls, @monsters, @loot) ->

  @fromAscii: (rows) ->
    walls = []
    monsters = []
    loot = []
    player = null
    _(rows).each (row, y) ->
      _(row.split("")).each (char, x) ->
        if char == "#" then walls.push(Point.at(x, y))
        if char == "!" then monsters.push(Point.at(x, y))
        if char == "$" then loot.push(Point.at(x, y))
        if char == "@" then player = Point.at(x, y)
    new Map(player, walls, monsters, loot)

  draw: (context) ->
    _(new DrawingTools(context)).tap (d) ->
      d.grid(WIDTH, HEIGHT, TILE_SIZE, Color.gray(0.9))
      context.fillStyle = Color.gray()
      _(map.walls).each (point) ->
        d.square(point.fromTile(TILE_SIZE), TILE_SIZE)
