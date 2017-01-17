
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
    # @model.start()
    @trigger('start')

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

class CountdownView extends Mn.LayoutView
  template: require './templates/countdown'
  className: 'row'
#  countdownCount = 3
  countdownCount = 1 # speed up for testing

  ui:
    counter: '[data-display=count]'

  templateHelpers: ->
    return { count: @countdownCount }

  onRender: ->
    @setCount(3, 0)
#    @setCount(2, 1000)
#    @setCount(1, 2000)

    setTimeout( =>
      @model.start()
#    , 3000)
    , 1000)


  setCount: (count, timeout) ->
    setTimeout( =>
      @ui.counter.text(count)
    , timeout)

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
    counterRegion:  '[data-region=counter]'
    controlsRegion: '[data-region=controls]'
    endRegion:      '[data-region=end]'
    progressRegion: '[data-region=progress]'

  modelEvents:
    'start':    'onStart'
    'end':      'onEnd'
    'restart':  'onRestart'
    'download': 'onDownload'

  onRender: ->
    startView = new StartView({ model: @model })
    startView.on 'start', => @onBeforeStart()
    @startRegion.show(startView)

  onRestart: ->
    @render()

  onBeforeStart: ->
    @startRegion.empty()
    @counterRegion.show new CountdownView({ model: @model })

  onStart: ->
    @counterRegion.empty()
    @controlsRegion.show new ControlsView({ model: @model })
    @progressRegion.show new ProgressView({ model: @model })

  onEnd: ->
    @controlsRegion.empty()
    @progressRegion.empty()
    @endRegion.show new EndView({ model: @model })

  onDownload: (raw_txt) ->

    donwloadOptions =
      filename: moment().format('x')#'download.csv' # todo: dynamically name this
      type:     'text/plain'
      content:  raw_txt

    # @downloadFile method defined in the DownloadFile behavior
    # (beahviors/downloadFile.coffee)
    @downloadFile(donwloadOptions)

# # # # #

module.exports = TestLayoutView
