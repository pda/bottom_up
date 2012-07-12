describe "Map", ->

  map = Map.fromAscii(32, [
    "### $"
    " @!$ "
    "! ###"
  ])

  list = (points) ->
    _(points).map((p) -> p.toString()).join(" ")

  describe ".fromAscii()", ->
    it "parses @ as player", ->
      expect(map.player).toEqual(Point.at(1, 1))
    it "parses # as walls", ->
      expect(list(map.walls)).toEqual("0,0 1,0 2,0 2,2 3,2 4,2")
    it "parses ! as monsers", ->
      expect(list(map.monsters)).toEqual("2,1 0,2")
    it "parses $ as loot", ->
      expect(list(map.loot)).toEqual("4,0 3,1")

  describe "draw()", ->
    it "should be tested"
