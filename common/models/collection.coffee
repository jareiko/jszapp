bb = if Backbone? then Backbone else require 'backbone'

module.exports = class Collection extends bb.Collection
