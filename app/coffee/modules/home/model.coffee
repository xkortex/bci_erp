# Defines the test protocol class which will build the events and stuff

class TestModel extends Backbone.Model

  defaults:
    # these will be overridden by testparams.json. Just a prototype to show the format
    oddball: {}
    timeout:  1000
    meanTimeout: 1000
    trialTones:    ['A4','C4','A4','C4','C4','C4','A4']
    toneLow:  'F4'
    toneHigh: 'G5'
    answer_events:  []
    tone_events: []
    events: []
    running: false
    filename: 'unnamed.txt'
    idx: 0
    runlength: 10
    progbarVisible: false # actual erp wants minimal distraction - probably closed-eyed
    playEndTones: true

    # bring BOSE noise cancelling - actually nvm speakers
    # P3 Pz P4 or FC F3 F4 central vs peripheral, frontal vs parietal
    # students are not entirely the most advanced of the neuroscience students (in terms of prereq)

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
    filename = 'oddball_run_' + moment().format('YYYY-MM-DD_HH-mm-ss') + '.csv'
    console.log('Output filename: ' + filename)
    @set('filename',  filename)  # 2017-01-18_15-04-20-oddball.txt
    @set('trialTones', oddball.trialTones)
    @set('runlength', oddball.trialTones.length)
    @set('timeout', oddball.timeout)
    console.log('timeout', oddball.timeout)
    #todo: just put this all in the object and call into it
    @set('idx', 0)
    console.log("Bound new experiment to model")
#    data =
#      tone:       null
#      resp:       null
#      timestamp:  @default_timestamp()
#      unixtime:  moment().format('x')
#      eventcode:  oddball.numcodes['start_exp']
#      labelname:  'start experiment'
    eventcode = @get('oddball').numcodes['start_exp']
    data = @packDataObj(null, null, eventcode, 'start experiment')
    @get('events').push(data) # keep track of event types separately from master log, for event triggers and such
    console.log(data)


  halt: ->
    @set('running', false)
    console.log("Manually halted, running = ", @get('running'))

  start: ->
    @set('running', true)
    console.log("Starting")


    trialTones = @get('trialTones')
    i = 0
    setTimeout(@initiate_experiment(), 1000)
#    for tone, index in @get('trialTones')
#      console.log("start, trialTones", tone)
#      @makeTone(tone, index * @get('timeout'))

  initiate_experiment: =>
    console.log('Initiate')
    @trigger('start')

    @tick() # fire off the pattern sequence

  tick: =>
    idx = @get('idx')
    if idx >= @get('runlength') || !@get('running')
      @set('running', false)
      console.log('Experiment completed')
      @end()
      return
    console.log('tick, running = ', @get('running'))
    @playNextTone()
#    @makeTone()
    # Update the internal timeout based on a random (normal) variable
    oddball = @get('oddball')
    @set('timeout', oddball.get_random_timeout());
    setTimeout(@tock, @get('timeout') * 0.75 )


  tock: =>
    idx = @get('idx')
    idx += 1
    @set('idx', idx)
#    console.log('tock')
    setTimeout(@tick, @get('timeout') * 0.25 )

  default_timestamp: ->
    return moment().format('YYYY-MM-DDTHH:mm:ss.SSSZ') # ISO 8601 with ms
#    return moment().format()

  packDataObj: (tone, resp, eventcode, eventname) ->
    data =
      tone:       tone
      resp:       resp
      timestamp:  @default_timestamp()
      unixtime:  moment().format('x')
      eventcode:  eventcode
      labelname:  eventname
    return data

  addAnswer: (answer) ->
    oddball = @get('oddball')
    eventname = 'response_freq' if answer == '1'
    eventname = 'response_infreq' if answer == '2'
    eventcode = oddball.numcodes[eventname]
#    console.log('Eventcode', eventcode)
    data = @packDataObj(null, answer, eventcode, eventname)
    console.log(data)
    @get('events').push(data)
    @get('answer_events').push(data)
    @trigger('answer')

    # Ends if all tones have been answered - disabled because we want all tones to play
#    @end() if answer_events.length == @get('trialTones').length

  end: ->
    @trigger('end')
#    data =
#      tone:       null
#      resp:       null
#      timestamp:  @default_timestamp()
#      unixtime:  moment().format('x')
#      eventcode:  @get('oddball').numcodes['stop_exp']
#      labelname:  'stop experiment'
    eventcode =  @get('oddball').numcodes['stop_exp']
    data = @packDataObj(null, null, eventcode, 'stop experiment')

    @get('events').push(data)
    @zelda() if @get('playEndTones')
    @download()

  restart: ->
    @set('answer_events', [])
    @set('tone_events',[])
    @set('events', [])
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
      row.push obj.unixtime
      row.push obj.resp || 0
      row.push obj.tone || 0
      row.push obj.eventcode || 0
      row.push obj.labelname || 0
      return row.join(',')

    downloadString += 'isotime,unixtime,resp,tone,type,label\n'


    # Assembles CSV results
    for each in @get('events')
      downloadString += makeRow(each) + "\n"

    # Assembles CSV results
#    for each in @get('answer_events')
#      downloadString += makeRow(each) + "\n"

    return downloadString

  playNextTone: ->
    idx = @get('idx')
    tones = @get('trialTones')
    tone = tones[idx]
    @playToneRecord(tone)

  playTone: (tone) ->
    @synth.triggerAttackRelease(tone, "8n")

  playToneRecord: (tone) ->
    oddball = @get('oddball')
    # todo: refact this to use enums or something, also merge with the answer event. DRY.
    eventname = 'stimulus_freq' if tone == oddball.toneLow
    eventname = 'stimulus_infreq' if tone == oddball.toneHigh
    eventname ||= 'error1'
    eventcode = oddball.numcodes[eventname]
    console.log('Eventcode playToneRecord', eventcode)
#    data =
#      tone: tone
#      resp: null
#      timestamp: @default_timestamp()
#      unixtime:  moment().format('x')
#      eventcode:  eventcode
#      labelname:  eventname
    data = @packDataObj(tone, null, eventcode, eventname)

    @get('events').push(data)
    @get('tone_events').push(data)
    @playTone(tone)
#    console.log("playToneRecord", tone)
    console.log(data)
    @trigger('tonePlayed')

  makeTone: (tone, time) ->
    setTimeout( =>
      return if !@get('running')
      @playToneRecord(tone)
    , time)

  zelda: ->
    # arpeggio: F A B C#  F# A# C D  A B C# D#  A# C D E  B C# D# F#?
    # chords: C/A chromatic rising
    synth = new Tone.PolySynth(6, Tone.Synth).toMaster();
    #set the attributes using the set interface
    synth.set("detune", -0);
    cadence = 160
    seq = [["C5", "A5"], ["C#5", "A#5"], ["D5", "B5"], ["D#5", "C6"]]
#    seq = [["C5"], ["C#5"], ["D5"], ["D#5"]]
    t1 = .15
    #play a chord
    setTimeout( =>
      synth.triggerAttackRelease(seq[0], t1)
    , cadence *0)
    setTimeout( =>
      synth.triggerAttackRelease(seq[1], t1)
    , cadence *1)
    setTimeout( =>
      synth.triggerAttackRelease(seq[2], t1)
    , cadence *2)
    setTimeout( =>
      synth.triggerAttackRelease(seq[3], "4n")
    , cadence *3)



# # # # # #

module.exports = TestModel
