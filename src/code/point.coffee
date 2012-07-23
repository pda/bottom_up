# A point in two dimentional space.
class @Point

  constructor: (@x, @y) ->

  @at: (x, y) ->
    new Point(x, y)

  toString: ->
    [@x, @y].join(",")

  toTile: (size) ->
    Point.at(Math.floor(@x / size), Math.floor(@y / size))

  fromTile: (size) ->
    half = size / 2
    Point.at(@x * size + half, @y * size + half)

  add: (other) ->
    Point.at(@x + other.x, @y + other.y)

  subtract: (other) ->
    Point.at(@x - other.x, @y - other.y)

  multiply: (scalar) ->
    Point.at(@x * scalar, @y * scalar)

  length: ->
    Math.sqrt(@x * @x + @y * @y)

  normalized: ->
    l = @length()
    Point.at(@x / l, @y / l)
