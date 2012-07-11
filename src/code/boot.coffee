vendors = [
  "vendor/underscore"
]

classes = [
  "color"
  "point"
]

require vendors, ->
  require classes, ->
    require ["game"]
