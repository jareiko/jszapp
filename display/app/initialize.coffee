application = require 'application'

$ ->
  application.initialize()
  Backbone.history.start
    root: '/display'
