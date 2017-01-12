LayoutView  = require './views/layout'
TestModel   = require '../model'
TestParams  = require './testparams'
Oddball     = require '../oddball'

# # # # #

class HomeRoute extends require '../../base/route'

  fetch: ->
    experiment = new Oddball()
    @model = new TestModel(TestParams) # why is this so convoluted?

  render: ->
    @container.show new LayoutView({ model: @model })

# # # # #

module.exports = HomeRoute
