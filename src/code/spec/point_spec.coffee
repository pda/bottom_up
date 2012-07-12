describe "Point", ->

  it "holds x and y coordinates", ->
    point = new Point(10, 20)
    expect(point.x).toBe(10)
    expect(point.y).toBe(20)

  describe ".at(x, y)", ->
    it "constructs a Point", ->
      expect(Point.at(2, 4)).toEqual(new Point(2, 4))

  describe "toTile(tileSize)", ->
    it "converts 10,20 to 2,5 for tileSize = 4", ->
      expect(Point.at(10, 20).toTile(4)).toEqual(Point.at(2, 5))

  describe "fromTile(tileSize)", ->
    it "converts 2,5 to 8,20 for tileSize = 4", ->
      expect(Point.at(2, 5).fromTile(4)).toEqual(Point.at(8, 20))

  describe "toString()", ->
    it "represents points as '2,4'", ->
      expect(Point.at(2, 4).toString()).toEqual("2,4")
