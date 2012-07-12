vendors = [
  "vendor/underscore"
]

classes = [
  "canvi"
  "color"
  "drawing_tools"
  "map"
  "point"
]

require vendors, ->
  require classes, ->
    require ["game"]
