class @Line

  constructor: (@from, @to) ->

  toArray: -> [@from, @to]

  toString: -> @toArray().join(":")

  isHorizontal: -> @from.y == @to.y
  isVertical: -> @from.x == @to.x

  # Single-direction continuation test.
  # Other lines "from" must start at this lines "to" position.
  isContinuation: (other) ->
    @to.isEqual(other.from) && (
      (@isHorizontal() && other.isHorizontal()) ||
      (@isVertical() && other.isVertical())
    )

  merge: (other) ->
    new Line(@from, other.to)
