application = require 'application'

module.exports = class Router extends Backbone.Router
  routes:
    '': 'home'
    'play': 'play'

  home: ->
    $('body').html application.setupView.render().el
    $('body').append application.playView.render().el
