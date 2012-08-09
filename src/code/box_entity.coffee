class @BoxEntity

  constructor: (@position) ->
    @halfSize = @size / 2
    @sizeDelta = Point.at(@halfSize, @halfSize)
    @velocity = Point.zero()

  # Move towards other point, return new distance remaining.
  moveTowards: (other, timeDelta, distance = 1) ->
    difference = other.subtract(@position)
    distance = Math.min(distance, difference.length())
    if distance > 0
      @velocity = difference.normalized().multiply(distance / timeDelta)
    else
      @stop()
    return distance

  # Set velocity to zero.
  stop: ->
    @velocity = Point.zero()

  # Update position, recalculating related coordinates.
  setPosition: (position) ->
    @position = position
    @top = position.subtract(@sizeDelta).y
    @bottom = position.add(@sizeDelta).y
    @left = position.subtract(@sizeDelta).x
    @right = position.add(@sizeDelta).x
    @corners = [
      Point.at(@left, @top),
      Point.at(@right, @top),
      Point.at(@left, @bottom),
      Point.at(@right, @bottom)
    ]

  # Draw the entity using DrawingTools
  draw: (drawingTools) ->
    drawingTools.square(@position, @size, @color())

  # Update position based on velocity and timeDelta.
  update: (timeDelta) ->
    @setPosition(@position.add(@velocity.multiply(timeDelta)))
