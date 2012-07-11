WIDTH = 800
HEIGHT = 600

# Representation and factory methods for RGBA colors.
class Color

  constructor: (@r, @g, @b, @a = 1.0) ->

  toString: ->
    "rgba(#{@r}, #{@g}, #{@b}, #{@a})"

  # Color.string(0, 255, 0, 0.5) => "rgba(0, 255, 0, 0.5)"
  @string: (r, g, b, a = 1.0) ->
    new Color(r, g, b, a).toString()

  # Color.black() => "rgba(0, 0, 0, l.0)"
  @black: (alpha = 1.0) ->
    @string(0, 0, 0, alpha)

  # Color.white() => "rgba(255, 255, 255, l.0)"
  @white: (alpha = 1.0) ->
    @string(255, 255, 255, alpha)

  # Color.gray(128) => "rgba(128, 128, 128, 1.0)"
  @gray: (lightness = 128, alpha = 1.0) ->
    @string(lightness, lightness, lightness, alpha)

  # Returns a function which, when called repeatedly, returns the specified
  # color with the alpha channel fading from 1.0 to 0.0 over the specified
  # amount of time.
  @fader: (r, g, b, seconds, initial = 1) ->
    start = Date.now()
    ->
      elapsed = (Date.now() - start) / 1000
      alpha = Math.max(0, initial - elapsed / seconds * initial)
      Color.string(r, g, b, alpha)

class Page

  constructor: (@document) ->
    @body = @document.body
    @layers = {}
    @contexts = {}

  addLayers: (width, height, names...) ->
    _(names).each (name) =>
      canvas = @buildCanvas(width, height, @buildId(name))
      @layers[name] = canvas
      @contexts[name] = canvas.getContext("2d")
      @body.appendChild(canvas)

  buildId: (name) ->
    "canvas_#{name}"

  # Build a canvas element.
  buildCanvas: (width, height, id) ->
    _.tap @document.createElement("canvas"), (c) ->
      c.width = width
      c.height = height
      c.id = id
      c.style.position = "absolute"

@page = new Page(document)
page.addLayers(WIDTH, HEIGHT, "back", "main", "front")

offset = 48
_(page.contexts).each (layer, name) ->
  console.log(layer)
  layer.font = "48px Helvetica"
  layer.fillStyle = "green"
  layer.textAlign = "center"
  layer.fillText name, WIDTH / 2, offset
  offset += 48
