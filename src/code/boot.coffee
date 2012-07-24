vendors = [
  "vendor/underscore"
]

classes = [
  "canvi"
  "color"
  "drawing_tools"
  "line"
  "map"
  "point"
]

require vendors, ->
  require classes, ->
    require ["game"]
