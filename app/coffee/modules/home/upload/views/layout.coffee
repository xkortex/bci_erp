
class UploadView extends Marionette.LayoutView
  template: require './templates/layout'
  className: 'container-fluid'

  # # # # #
  # UI Tutorial
  # ui:
  #   'btn': '[data-click=test]'

  # events:
  #   'click @ui.btn:not(.disabled)': 'onTestClick'

  # onTestClick: ->
  #   @ui.btn.addClass('disabled')
  #   setTimeout(@onSync, 1500)

  # onSync: =>
  #   @ui.btn.removeClass('disabled')
  # # # # #

  events:
    'change input[type=file]': 'onInputChange'

  onInputChange: (e) ->
    console.log 'ON CHANGE'
    target = e.target
    fr = new FileReader()
    fr.onload = => @onUpload(fr.result)
    fr.readAsDataURL(target.files[0])

  onUpload: (fileData) ->
    console.log 'UPLOADED FILE'
    console.log fileData

# # # # #

module.exports = UploadView
