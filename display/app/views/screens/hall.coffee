Screen = require './screen'

module.exports = class Intro extends Screen
  constructor: (screen, engine) ->
    super
    engine.addCenterText @, screen, 1,   0x009000, 10, screen.title if screen.title
    engine.addCenterText @, screen, 0.5, 0x009000, 9,  screen.subtitle if screen.subtitle

    return unless screen.highscores

    @add container = new THREE.Object3D
    counter = 0
    @update = (deltaTime) ->
      return unless (counter += deltaTime) >= 1
      counter = 0
      users = engine.game.users.models
      ranking = [0...users.length]
      ranking.sort (a, b) ->
        return users[b].points - users[a].points

      while child = container.children[0]
        container.remove child

      for i in [0..2]
        u = users[ranking[i]]
        continue unless u
        msg = "#{i+1}: #{u.name} (#{u.points})"
        engine.addText container, 0.5, 0x101010, 8.5, 9 - i, msg
