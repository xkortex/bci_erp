LayoutView  = require './views/layout'
TestModel   = require '../model'

# # # # #

class HomeRoute extends require '../../base/route'

  fetch: ->
    @model = new TestModel({
      tones: ['A4', 'C4']
      timeout: 500
    })

  render: ->
    @container.show new LayoutView({ model: @model })

# # # # #

module.exports = HomeRoute
