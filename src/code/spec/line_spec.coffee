describe "Line", ->

  p = (x, y) -> Point.at(x, y)
  l = (a, b, c, d) -> new Line(p(a, b), p(c, d))

  it "holds two points", ->
    line = new Line(p(10, 20), p(30, 20))
    expect(line.from).toEqual(p(10, 20))
    expect(line.from).toEqual(p(10, 20))

  describe "#toArray", ->
    expect(l(1,2,3,4).toArray()).toEqual([p(1,2), p(3,4)])

  describe "#toString", ->
    expect(l(1,2,3,4).toString()).toEqual("1,2:3,4")

  describe "line from 10,20 to 30,20", ->
    line = new Line(p(10, 20), p(30, 20))
    it "is horizontal", ->
      expect(line.isHorizontal()).toBe(true)
    it "is not vertical", ->
      expect(line.isVertical()).toBe(false)

    it "is continuous with line from 30,20 to 40,20", ->
      other = new Line(p(30, 20), p(40, 20))
      expect(line.isContinuation(other)).toBe(true)
    it "is not continuous with line from 30,20 to 40,50", ->
      other = new Line(p(30, 20), p(40, 50))
      expect(line.isContinuation(other)).toBe(false)
    it "is not continuous with line from 30,50 to 40,50", ->
      other = new Line(p(30, 50), p(40, 50))
      expect(line.isContinuation(other)).toBe(false)

    it "merges with 30,20:40,20 to form 10,20:40,20", ->
      expect(line.merge(l(30,20,40,20))).toEqual(l(10,20,40,20))

  describe "line from 10,20 to 10,40", ->
    line = new Line(p(10, 20), p(10, 40))
    it "is not horizontal", ->
      expect(line.isHorizontal()).toBe(false)
    it "is vertical", ->
      expect(line.isVertical()).toBe(true)

    it "is continuous with line from 10,40 to 10,50", ->
      other = new Line(p(10, 40), p(10, 50))
      expect(line.isContinuation(other)).toBe(true)
    it "is not continuous with line from 10,40 to 50,10", ->
      other = new Line(p(10, 40), p(50, 10))
      expect(line.isContinuation(other)).toBe(false)

    it "merges with 10,40:10:50 to form 10,20:10,50", ->
      expect(line.merge(l(10,40,10,50))).toEqual(l(10,20,10,50))
