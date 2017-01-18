# Defines the test protocol class which will build the events and stuff

class TestModel extends Backbone.Model

  defaults:
    # these will be overridden by testparams.json. Just a prototype to show the format
    oddball: {}
    timeout:  1000
    trialTones:    ['A4','C4','A4','C4','C4','C4','A4']
    toneLow:  'C4'
    toneHigh: 'B4'
    answers:  []
    toneTimes: []
    running: false

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

  setup_experiment: ->
    oddball = @get('oddball')
    console.log("Firing experiment generator (default tones)", oddball.trialTones)
    oddball.generate_trial(16, .25)

    console.log("New Tones", oddball.trialTones)
    @set('trialTones', oddball.trialTones)
    console.log("Bound new experiment to model")

  start: ->
    @set('running', true)
    @trigger('start')
    console.log("Starting")

    trialTones = @get('trialTones')
    i = 0
    for tone, index in @get('trialTones')
#    while i < trialTones.length
      console.log("start, trialTones", tone)
      @makeTone(tone, index * @get('timeout'))

  halt: ->
    @set('running', false)
    console.log("Manually halted")


  addAnswer: (answer) ->

    data =
      resp:       answer
      timestamp:  moment().format('x'),

    answers = @get('answers')
    answers.push(data)
    @trigger('answer')

    # Ends if all tones have been answered
    @end() if answers.length == @get('trialTones').length

  end: ->
    @trigger('end')
    @download()

  restart: ->
    @set('answers', [])
    @set('toneTimes',[])
    @trigger('restart')

  # Formats download string & triggers view to download file
  download: ->
    downloadString = @formatDownload()
    @trigger('download', downloadString)

  formatDownload: ->
    downloadString = ''

    makeRow = (obj) ->
      row = []
      row.push obj.timestamp
      row.push obj.resp || 0
      row.push obj.tone || 0
      return row.join(',')

    # Assembles CSV results
    for each in @get('toneTimes')
      downloadString += makeRow(each)
      downloadString += "\n"

    # Assembles CSV results
    for each in @get('answers')
      downloadString += makeRow(each)
      downloadString += "\n"

    return downloadString

  playTone: (tone) ->
    @synth.triggerAttackRelease(tone, "8n")

  playToneRecord: (tone) ->
    @get('toneTimes').push({tone: tone, timestamp: moment().format('x'), resp: null })
    @playTone(tone)
    console.log("playToneRecord")

  makeTone: (tone, time) ->
    setTimeout( =>
      return if !@get('running')
      @playToneRecord(tone)
    , time)

# # # # # #

module.exports = TestModel
