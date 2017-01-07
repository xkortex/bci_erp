# Defines the test protocol class which will build the events and stuff

class TestModel extends Backbone.Model

  defaults:
    # these will be overridden by testparams.json. Just a prototype to show the format
    timeout:  1000
    tones:    ['A4','C4','A4','C4','C4','C4','A4']
    toneLow: 'C4'
    toneHigh: 'B4'
    answers:  []
    toneTimes: []

  initialize: (options={}) ->
    @synth = new Tone.Synth(
      oscillator: {
        type: "square"
      }
      envelope: {
        attack:  0.00
        decay:   0.3
        sustain: 0.25
        release: 0.5
      }
    ).toMaster()

  start: ->
    @trigger('start')
    for tone, index in @get('tones')
      @makeTone(tone, index * @get('timeout'))

  addAnswer: (answer) ->

    data =
      resp: answer

    answers = @get('answers')
    answers.push(data)
    @trigger('answer')

    # Ends if all tones have been answered
    @end() if answers.length == @get('tones').length

  end: ->
    @trigger('end')
    @download()

  restart: ->
    @set('answers', [])
    @set('toneTimes',[])
    @trigger('restart')

  # TODO - auto-download
  # TODO - format data?
  download: ->
    console.log 'SAVE ANSWERS'
    console.log @get('answers')
    console.log @get('toneTimes')

  playTone: (tone) ->
    @synth.triggerAttackRelease(tone, "8n")


  playToneRecord: (tone) ->
    @get('toneTimes').push({tone: tone, timestamp: moment().format('x'), resp: '0'})
    @playTone(tone)

  makeTone: (tone, time) ->
    setTimeout( =>
      @playToneRecord(tone)
    , time)

# # # # # #

module.exports = TestModel
