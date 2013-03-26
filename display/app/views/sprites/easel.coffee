Sprite = require './sprite'

module.exports = class Bunny extends Sprite
  textureUrl: 'textures/easel.png'

  scaleX: 6
  scaleY: 6

  constructor: ->
    super
    @mesh.position.y = 3
