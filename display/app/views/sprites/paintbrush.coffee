Sprite = require './sprite'

module.exports = class Paintbrush extends Sprite
  textureUrl: 'textures/paintbrush.png'

  scaleX: 1.5 * 33 / 256
  scaleY: 1.5

  constructor: ->
    super
    @mesh.position.y = @scaleY / 2
