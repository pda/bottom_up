WIDTH = 800
HEIGHT = 600


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
