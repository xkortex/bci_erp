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
    filename: 'unnamed.txt'
    idx: 0
    runlength: 10

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
    # Reset the experiment
    oddball = @get('oddball')
    console.log("Firing experiment generator (default tones)", oddball.trialTones)
#    oddball.generate_trial(200, .1)
    oddball.generate_default_trial()

    console.log("New Tones", oddball.trialTones)
    @set('filename', 'oddball_run_' + moment().format('YYYY-MM-DD_HH-MM-SS')) # 2017-01-18_15-04-20-oddball.txt
    @set('trialTones', oddball.trialTones)
    @set('runlength', oddball.trialTones.length)
    @set('timeout', oddball.timeout)
    console.log('timeout', oddball.timeout)
    #todo: just put this all in the object and call into it
    @set('idx', 0)
    console.log("Bound new experiment to model")

  halt: ->
    @set('running', false)
    console.log("Manually halted, running = ", @get('running'))

  start: ->
    @set('running', true)
    @trigger('start')
    console.log("Starting")

    trialTones = @get('trialTones')
    i = 0

    @tick()
#    for tone, index in @get('trialTones')
#      console.log("start, trialTones", tone)
#      @makeTone(tone, index * @get('timeout'))

  tick: =>
    idx = @get('idx')
    if idx >= @get('runlength') || !@get('running')
      @set('running', false)
      console.log('Experiment completed')
      return
    console.log('tick, running = ', @get('running'))
    @playNextTone()
#    @makeTone()
    setTimeout(@tock, @get('timeout') * 0.75 )


  tock: =>
    idx = @get('idx')
    idx += 1
    @set('idx', idx)
    console.log('tock')
    setTimeout(@tick, @get('timeout') * 0.25 )



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

  playNextTone: ->
    idx = @get('idx')
    tones = @get('trialTones')
    tone = tones[idx]
    @playToneRecord(tone)

  playTone: (tone) ->
    @synth.triggerAttackRelease(tone, "8n")

  playToneRecord: (tone) ->
    @get('toneTimes').push({tone: tone, timestamp: moment().format('x'), resp: null })
    @playTone(tone)
    console.log("playToneRecord", tone)

  makeTone: (tone, time) ->
    setTimeout( =>
      return if !@get('running')
      @playToneRecord(tone)
    , time)

# # # # # #

module.exports = TestModel
