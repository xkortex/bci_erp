LayoutView  = require './views/layout'
TestModel   = require '../model'
TestParams  = require './testparams'
OddballTrial     = require '../oddball'

# # # # #

class HomeRoute extends require '../../base/route'

  fetch: ->
    experiment = new OddballTrial(42)
    experiment.generate_default_trial()
    @model = new TestModel(TestParams) # why is this so convoluted?

  render: ->
    @container.show new LayoutView({ model: @model })

# # # # #

module.exports = HomeRoute
