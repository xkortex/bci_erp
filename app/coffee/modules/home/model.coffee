
class TestModel extends Backbone.Model

  defaults:
    timeout:  1000
    tones:    ['A4','C4','A4','C4','C4','C4','A4']
    answers:  []

  initialize: (options={}) ->
    @synth = new Tone.Synth().toMaster()

  start: ->
    @trigger('start')
    for tone, index in @get('tones')
      @makeTone(tone, index * @get('timeout'))

  addAnswer: (answer) ->

    data =
      resp:       answer
      timestamp:  new Date()

    answers = @get('answers')
    answers.push(data)
    @trigger('answer')

    # Ends if all tones have been answered
    @end() if answers.length == @get('tones').length

  end: ->
    @trigger('end')

  restart: ->
    @download()
    @set('answers', [])
    @trigger('restart')

  # TODO - auto-download
  # TODO - format data?
  download: ->
    console.log 'SAVE ANSWERS'
    console.log @get('answers')

  makeTone: (tone, time) ->
    setTimeout( =>
      @synth.triggerAttackRelease(tone, "8n")
    , time)

# # # # # #

module.exports = TestModel
