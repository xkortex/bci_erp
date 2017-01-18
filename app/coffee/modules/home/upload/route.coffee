LayoutView  = require './views/layout'

# # # # #

class UploadRoute extends require '../../base/route'

  render: ->
    @container.show new LayoutView()

# # # # #

module.exports = UploadRoute
