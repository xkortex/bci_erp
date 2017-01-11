
# Callback to destroy clicked downloadLink
destroyClickedElement = (e) -> $(e.currentTarget).remove()

# Default options for downloadFile method
defaultOptions =
  filename: 'download.txt'
  type:     'text/plain'
  content:  null

# # # # #

class DownloadFileBehavior extends Marionette.Behavior

  initialize: (options={}) ->
    @view.downloadFile = @downloadFile

  downloadFile: (options={}) ->

    # Extend in default options
    options = _.extend defaultOptions, options

    # File contents & type
    textFileAsBlob = new Blob([ options.content ], { type: options.type })

    # Preview (open in new tab)
    return window.open(window.URL.createObjectURL(textFileAsBlob),'_blank') if options.preview

    # Assembles downloadLink
    downloadLink                = document.createElement('a')
    downloadLink.download       = options.filename
    downloadLink.innerHTML      = 'Download File'
    downloadLink.href           = window.URL.createObjectURL(textFileAsBlob)
    downloadLink.onclick        = destroyClickedElement
    downloadLink.style.display  = 'none'

    # Appends downloadLink & triggers click
    document.body.appendChild downloadLink
    downloadLink.click()

# # # # #

module.exports = DownloadFileBehavior
