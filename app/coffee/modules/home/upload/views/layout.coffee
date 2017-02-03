
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
#    fr.readAsDataURL(target.files[0]) # encoded data
    fr.readAsText(target.files[0]) # do this if you wanna grab the whole dataframe


  onUpload: (fileData) ->
    console.log 'UPLOADED FILE'
#    console.log fileData
    console.log fileData.length

# # # # #

module.exports = UploadView
