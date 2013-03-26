Sprite = require './sprite'

module.exports = class Bunny extends Sprite
  textureUrl: 'textures/bunnysprite.png'
  scaleX: 1.4
  scaleY: 1.4
  gridX: 6
  gridY: 3
  anims:
    'idle': [
      { c: [0,0], s: [1,1], t: 0.5 }
      { c: [1,0], s: [1,1], t: 0.5 }
    ]
    'earsup': [
      { c: [0,0], s: [1,1], t: 0.5 }
    ]
    'earsdown': [
      { c: [1,0], s: [1,1], t: 0.5 }
    ]
    'right': [
      { c: [0,2], s: [1,1], t: 0.07 }
      { c: [1,2], s: [1,1], t: 0.07 }
      { c: [2,2], s: [1,1], t: 0.07 }
      { c: [3,2], s: [1,1], t: 0.07 }
      { c: [4,2], s: [1,1], t: 0.07 }
      { c: [5,2], s: [1,1], t: 0.07 }
    ]
    'left': [
      { c: [0,2], s: [-1,1], t: 0.07 }
      { c: [1,2], s: [-1,1], t: 0.07 }
      { c: [2,2], s: [-1,1], t: 0.07 }
      { c: [3,2], s: [-1,1], t: 0.07 }
      { c: [4,2], s: [-1,1], t: 0.07 }
      { c: [5,2], s: [-1,1], t: 0.07 }
    ]
    'jumpright': [
      { c: [4,2], s: [1,1], t: 0.15 }
      { c: [5,2], s: [1,1], t: 0.15 }
    ]
    'jumpleft': [
      { c: [4,2], s: [-1,1], t: 0.15 }
      { c: [5,2], s: [-1,1], t: 0.15 }
    ]

  constructor: ->
    super
    @setAnimation 'idle'
    @mesh.position.y = 0.5
