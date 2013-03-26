Sprite = require './sprite'

module.exports = class Cloud extends Sprite
  textureUrl: 'textures/clouds.png'

  gridX: 1
  gridY: 2

  scaleX: 32
  scaleY: 16

  # TODO: Pick a random cloud.
  constructor: ->
    super
    v1 = Math.floor Math.random() * 2
    v2 = 1 - 2 * Math.floor Math.random() * 2
    @setSprite { c: [0,v1], s: [v2,1] }
