vendors = [
  "vendor/underscore"
]

classes = [
  "box_entity"
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
