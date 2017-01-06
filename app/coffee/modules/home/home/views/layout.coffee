
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

  events:
    'click @ui.start': 'start'

  start: ->
    @model.start()

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

  regions:
    startRegion:    '[data-region=start]'
    controlsRegion: '[data-region=controls]'
    endRegion:      '[data-region=end]'
    progressRegion: '[data-region=progress]'

  modelEvents:
    'start':    'onStart'
    'end':      'onEnd'
    'restart':  'onRestart'

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

# # # # #

module.exports = TestLayoutView
