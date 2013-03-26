bb = Backbone ? require 'backbone'
__ = _ ? require 'underscore'

module.exports =
  name: 'audio'
  tiles: [
    [ 1, 1, 1, 1, 2 ]
    [ 1, 1, 1, 1, 2 ]
    [ 1, 1, 1, 2 ]
    [ 1, 1, 1, 2, 4, 0, 3, 5, 0, 0, 0]
    [ 1, 1, 1, 2, 0, 0, 4, 0, 4, 0, 0, 0 ]
    [ 1, 1, 1, 4, 0, 0, 0, 0, 0, 0, 0 ]
    [ 1, 1, 1, 2, 0, 3, 0, 0, 0, 4, 5, 0]
    [ 1, 2, 4, 2, 0, 0, 3, 5, 0, 4, 0 ]
    [ 1, 2, 0, 2, 3, 0, 0, 0, 0, 4, 5, 0 ]
    [ 1, 2, 0, 2, 0, 0, 0, 4, 0, 0, 0 ]
    [ 1, 2, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0 ]
    [ 1, 2, 0, 2, 0, 0, 0, 0, 4, 0, 0 ]
    [ 1, 2, 0, 2, 4, 0, 0, 0, 0, 0, 0, 0 ]
    [ 1, 2, 0, 2, 0, 0, 0, 0, 4, 5, 0 ]
    [ 1, 2, 5, 0, 2, 0, 0, 0, 0, 4 ]
    [ 1, 1, 2, 0, 4, 2 ]
    [ 1, 1, 1, 1, 2 ]
    [ 1, 1, 1, 2 ]
    [ 1, 1, 1, 2 ]
  ]

  initialize: (game) ->
    noteblocks = []
    for col, x in @tiles
      for tileId, y in col
        if tileId is 4
          noteblocks.push game.getTileObject x + @offset, y
    semitone = Math.pow 2, 1/12
    scale = [ 0, 2, 4, 5, 7, 9, 11 ]

    for noteblock, i in noteblocks
      __.extend noteblock, bb.Events
      note = scale[i % scale.length]
      octave = Math.floor i / scale.length
      pitch = Math.pow(semitone, note) * Math.pow(2, octave)
      do (noteblock, pitch) ->
        noteblock.on 'hit', (user, velocity) ->
          volume = 0.3 * Math.log velocity
          game.trigger 'playsound', 'note', volume, pitch if volume >= 0.1
    return
