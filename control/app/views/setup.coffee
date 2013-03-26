app       = require 'application'
View      = require './view'

module.exports = class SetupView extends View
  id: 'setup-view'

  template: require './templates/setup'

  events:
    "input #userName": "changeName"
    #"click #playButton": "play"

  afterRender: ->
    @$name = @$('#userName')
    #$name.val 'Player One'  # using placeholder now
    #$name.focus()  # Doesn't seem to work :/
    @changeName()

    do updatePoints = =>
      $('#points').text app.user.points
    app.user.on 'change:points', updatePoints

  changeName: ->
    app.user.set { name: @$name.val() }, validate: yes
