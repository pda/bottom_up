vendors = [
  "vendor/underscore"
]

classes = [
  "color"
  "drawing_tools"
  "point"
]

require vendors, ->
  require classes, ->
    require ["game"]
