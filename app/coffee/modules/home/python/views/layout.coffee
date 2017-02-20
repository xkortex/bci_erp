
class PythonRunView extends Marionette.LayoutView
  template: require './templates/layout'
  className: 'container-fluid'

  ui:
    'scriptInput': 'input[name=script]'

  events:
    'click [data-click=run]': 'runPython'

  showError: ->
    msg = 'Server Worker is not present.'
    Backbone.Radio.channel('flash').trigger('error', { message: msg })

  runPython: (e) ->
    script = @ui.scriptInput.val()

    # Return and show error flash
    return @showError() unless script && window.global

    # # # # #
    # TODO - an alternative interface should be defined
    # Using window.global isn't ideal.

    # Run without arguments
    window.global.ServerWorker.invokePython(script)

    # Run with arguments (example)
    # window.global.ServerWorker.invokePython(script, ['arg1', 'arg2', 'arg3'])

# # # # #

module.exports = PythonRunView
