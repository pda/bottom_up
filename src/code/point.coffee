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
    Point.at(@x * size, @y * size)
