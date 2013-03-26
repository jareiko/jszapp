Terrain = require '../sprites/terrain'

module.exports = class Screen extends THREE.Object3D
  constructor: (@screen, @engine) ->
    super()

    tileKey = @engine.game.tileKey

    for column, x in screen.tiles ? []
      for tile, y in column
        name = tileKey[tile].name
        continue unless name
        @add t = new Terrain name
        t.position.x = x + 0.5
        t.position.y = y + 0.5
