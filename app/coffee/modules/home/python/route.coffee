LayoutView  = require './views/layout'

# # # # #

class PythonRunRoute extends require '../../base/route'

  render: ->
    @container.show new LayoutView()

# # # # #

module.exports = PythonRunRoute
