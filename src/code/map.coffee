class @Map

  constructor: (@width, @height, @tileSize, @player, @walls, @monsters, @loot) ->

  @fromAscii: (tileSize, rows) ->
    width = tileSize * rows[0].length
    height = tileSize * rows.length
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
    new Map(width, height, tileSize, player, walls, monsters, loot)

  draw: (context) ->
    _(new DrawingTools(context)).tap (d) =>
      d.grid(@width, @height, @tileSize, Color.gray(0.9))
      context.fillStyle = Color.gray()
      _(@walls).each (point) =>
        d.square(point.fromTile(@tileSize), @tileSize, Color.gray(0.8))
