vendors = [
  "vendor/underscore"
]

classes = [
  "color"
  "drawing_tools"
  "map"
  "point"
]

require vendors, ->
  require classes, ->
    require ["game"]
