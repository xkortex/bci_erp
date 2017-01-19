HomeRoute   = require './home/route'
UploadRoute = require './upload/route'
PythonRoute = require './python/route'

# # # # #

# HomeRouter class definition
class HomeRouter extends require '../base/router'

  routes:
    '(/)':        'home'
    'upload(/)':  'upload'
    'python(/)':  'python'

  home: ->
    new HomeRoute({ container: @container })

  upload: ->
    new UploadRoute({ container: @container })

  python: ->
    new PythonRoute({ container: @container })

# # # # #

module.exports = new HomeRouter({ container: window.Layout.mainRegion })
