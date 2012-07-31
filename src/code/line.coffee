class @Line

  constructor: (@from, @to) ->

  toArray: -> [@from, @to]

  toString: -> @toArray().join(":")

  isHorizontal: -> @from.y == @to.y
  isVertical: -> @from.x == @to.x

  # http://cgafaq.info/wiki/Intersecting_line_segments_(2D)
  intersects: (other) ->
    a = @from
    b = @to
    c = other.from
    d = other.to
    r = ((a.y - c.y) * (d.x - c.x) - (a.x - c.x) * (d.y - c.y)) /
      ((b.x - a.x) * (d.y - c.y) - (b.y - a.y) * (d.x - c.x))
    s = ((a.y - c.y) * (b.x - a.x) - (a.x - c.x) * (b.y - a.y)) /
      ((b.x - a.x) * (d.y - c.y) - (b.y - a.y) * (d.x - c.x))
    return (0 <= r && r <= 1) && (0 <= s && s <= 1)

  # Single-direction continuation test.
  # Other lines "from" must start at this lines "to" position.
  isContinuation: (other) ->
    @to.isEqual(other.from) && (
      (@isHorizontal() && other.isHorizontal()) ||
      (@isVertical() && other.isVertical())
    )

  merge: (other) ->
    new Line(@from, other.to)
