
class ProgressView extends Mn.LayoutView
  template: require './templates/progress'
  className: 'row'

  modelEvents:
    'answer': 'render'

# # # # #

class StartView extends Mn.LayoutView
  template: require './templates/start'
  className: 'row'

  ui:
    start: '[data-click=start]'
    play: '[data-play]'

  events:
    'click @ui.start': 'start'
    'click @ui.play': 'play'

  play: (e) ->
    tone = $(e.currentTarget).data('play')
    @model.playTone(@model.get('toneLow')) if tone == 1
    @model.playTone(@model.get('toneHigh')) if tone == 2

  start: ->
    @model.start()

  # I think I know what I'm doing...
  initialize: ->
    $(document).on 'keydown', @keyAction

  onBeforeDestroy: ->
    $(document).off 'keydown', @keyAction

  keyAction: (e) =>
    e.preventDefault() if e.keyCode == 37 || e.keyCode == 39 || 32
    return @model.playTone(@model.get('toneHigh'))  if e.keyCode == 39 # right arrow
    return @model.playTone(@model.get('toneLow')) if e.keyCode == 37 # left arrow
    return @start() if e.keyCode == 32 # Start

# # # # #

class EndView extends Mn.LayoutView
  template: require './templates/end'
  className: 'row'

  ui:
    download: '[data-click=download]'
    restart:  '[data-click=restart]'

  events:
    'click @ui.download': 'download'
    'click @ui.restart':  'restart'

  download: ->
    @model.download()

  restart: ->
    @model.restart()

# # # # #

class ControlsView extends Mn.LayoutView
  template: require './templates/controls'
  className: 'row'

  ui:
    submit: '[data-submit]'

  events:
    'click @ui.submit': 'submitAnswer'

  initialize: ->
    $(document).on 'keydown', @keyAction

  onBeforeDestroy: ->
    $(document).off 'keydown', @keyAction

  keyAction: (e) =>
    e.preventDefault() if e.keyCode == 37 || e.keyCode == 39
    return @model.addAnswer('1')  if e.keyCode == 39
    return @model.addAnswer('2') if e.keyCode == 37

  submitAnswer: (e) ->
    answer = $(e.currentTarget).data('submit')
    @model.addAnswer(answer)

# # # # #

class TestLayoutView extends Mn.LayoutView
  template: require './templates/layout'
  className: 'container-fluid test-container'

  behaviors:
    DownloadFile: {}

  regions:
    startRegion:    '[data-region=start]'
    controlsRegion: '[data-region=controls]'
    endRegion:      '[data-region=end]'
    progressRegion: '[data-region=progress]'

  modelEvents:
    'start':    'onStart'
    'end':      'onEnd'
    'restart':  'onRestart'
    'download': 'onDownload'

  onRender: ->
    @startRegion.show new StartView({ model: @model })

  onRestart: ->
    @render()

  onStart: ->
    @startRegion.empty()
    @controlsRegion.show new ControlsView({ model: @model })
    @progressRegion.show new ProgressView({ model: @model })

  onEnd: ->
    @controlsRegion.empty()
    @progressRegion.empty()
    @endRegion.show new EndView({ model: @model })

  onDownload: (raw_txt) ->

    donwloadOptions =
      filename: 'download.csv'
      type:     'text/plain'
      content:  raw_txt

    # @downloadFile method defined in the DownloadFile behavior (beahviors/downloadFile.coffee)
    @downloadFile(donwloadOptions)

# # # # #

module.exports = TestLayoutView
