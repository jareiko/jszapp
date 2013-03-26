Sprite = require './sprite'

module.exports = class TerrainTile extends Sprite
  textureUrl: 'textures/terrain.png'
  gridX: 4
  gridY: 4

  tiles =
    'dirt':         { c: [0, 0], s: [ 1, 1] }
    'dirtgrass':    { c: [1, 0], s: [ 1, 1] }
    'floatgrass':   { c: [2, 0], s: [ 1, 1] }
    'noteblock':    { c: [1, 3], s: [ 1, 1] }
    'easteregg':  [ { c: [0, 2], s: [ 1, 1] }
                    { c: [1, 2], s: [ 1, 1] }
                    { c: [2, 2], s: [ 1, 1] } ]
    'torch':      [ { c: [3, 2], s: [ 1, 1] }
                    { c: [3, 2], s: [-1, 1] } ]

  setTile: (name) ->
    tile = tiles[name]
    if _.isArray tile
      tile = tile[Math.floor Math.random() * tile.length]
    @setSprite tile

  constructor: (name) ->
    super
    @setTile name if name
