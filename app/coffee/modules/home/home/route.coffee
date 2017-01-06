LayoutView  = require './views/layout'
TestModel   = require '../model'
TestParams  = require './testparams'

# # # # #

class HomeRoute extends require '../../base/route'

  fetch: ->
    @model = new TestModel(TestParams)

  render: ->
    @container.show new LayoutView({ model: @model })

# # # # #

module.exports = HomeRoute
