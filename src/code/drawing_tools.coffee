class @DrawingTools

  constructor: (context) ->
    @c = context

  line: (from, to) ->
    @c.beginPath()
    @c.moveTo(from.x, from.y)
    @c.lineTo(to.x, to.y)
    @c.stroke()

  grid: (width, height, size, style) ->
    @c.lineWidth = 1
    @c.strokeStyle = style
    _(width / size + 1).times (i) =>
      @line(Point.at(i * size, 0), Point.at(i * size, height))
    _(height / size + 1).times (i) =>
      @line(Point.at(0, i * size), Point.at(width, i * size))

  square: (point, size, style) ->
    if style then @c.fillStyle = style
    @c.fillRect(point.x, point.y, size, size)
