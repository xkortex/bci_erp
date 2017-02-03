## Programmatically generate the file testparams.coffee

fs = require "fs"

class OddballTrial
  #  constructor: (@dummy)  ->

  # Tones to be used by the module


  constructor: (options = {}) ->
    console.log("Constructor called on OddballTrial")
    @num_trials = 4 # Number of trials to run
    @num_pad = 0 # ensure at least num_pad low tones occur first
    @timeout = 1000 # Time in ms for each trial
    @timeout_mean = 2000 # ms
    @timeout_sigma = 333 # 95% interval = (mean) ms +/- 3*(sigma) ms
    @oddball_rate = 0.25 # This is the rate at which the oddball occurs
    @availableTones = ['F4', 'G5', 'F4'] # [lo, hi, end]
    # Only first two will be used for the random trials
    @toneLow = @availableTones[0]
    @toneHigh = @availableTones[1]
    @toneEnd = @availableTones[2]
    @trialTones = ['A5', 'B5', 'C5']
    # actual experiment will be about 6 minutes. 20 oddballs @ 10% rate and 1.5-2 s
    # todo: stochastic time interval 95% = +/- 500 ms
    # Numeric code uses bitmasks, because why not? May need to multiplex these, and ERPLAB seems not to care about
    # the actual numerical value
    @numcodes =
      frequentStim: 0x2
      infrequentStim: 0x4
      responseFreq: 0x12
      responseInfreq: 0x14


  dump: ->
    saved_params = {'timeout':@timeout, 'availableTones': @availableTones}
    localStorage.oddball_params = JSON.stringify(saved_params)
    console.log("dumping to oddball_params.json", saved_params)
#    fs.writeFile "saved_params.json", JSON.stringify(saved_params), (error) ->
#      console.error("Error writing file", error) if error


  conveyor: (ary) ->
    # First element goes to end of list. Creates a new object
    ary2 = (ary[n] for n in [1...ary.length])
    ary2.push(ary[0])
    return ary2


  max: (ary) ->
    return ary.reduce (t, s) -> Math.max(t, s)

  sum: (ary) ->
    accu = ary.reduce (t, s)->t + s
    return accu

    #    console.log(ary)
    #    accu = 0 # jesus christ why do I have to do this?
    #    console.log("Summing: #{ary} length: #{ary.length}")
    #    for i in [0...ary.length] # this is safe and i know it works
    #      console.log(Number(ary[i]))
    #      accu = accu + Number(ary[i]) # ffs why do I have to hand-hold this language every step of the way?

  # Standard Normal variate using Box-Muller transform.
  randn_bm: (mean, sigma) ->
    u = 1 - Math.random(); # Subtraction to flip [0, 1) to (0, 1].
    v = 1 - Math.random();
    return Math.sqrt( -2.0 * Math.log( u ) ) * Math.cos( 2.0 * Math.PI * v ) * sigma + mean

  get_random_timeout: () ->
    return @randn_bm(@timeout_mean, @timeout_sigma)


  check_for_adjacent: (bitlist) ->
    # Now we need to check to see if we have any adjacent ones
    bitlist2 = @conveyor(bitlist)
    sumlist = []
    sumlist.push(bitlist[i]+ bitlist2[i]) for i in [0...bitlist.length]
    valmax = @max(sumlist)
    if 1 == valmax
      return true
    return false


  get_weighted_bits: (p) ->
# p is the probability of returning a 1
    r = Math.random()
    if r < p
      return 1
    return 0

  get_weighted_bitlist: (n, p) ->
    return (@get_weighted_bits(p) for i in [0...n])

  get_asserted_list: (n, p) ->
# This will produce a list with EXACTLY p percent ones in it. This is so we do not get oddballs with no tones
    k = p * n
    k_int = Math.round(k)
    if not (k == k_int)
#      alert("#{k}, #{k_int}")
      throw "(Internal error) The product p*n must be an integer value."

    iters = 0
    while iters < 100
      bitlist = @get_weighted_bitlist(n, p)
      bitsum = @sum(bitlist)
      return bitlist if bitsum == k
      iters += 1

    throw "(Internal Error) Excessive loop occured in OddballTrial.get_asserted_list"


  get_asserted_epoch_list: (n, p) ->
# We want an experimental setup which is random, but not TOO random
# This ensures that we get a list with exactly p percent ones in it, AND we have one bit per each "epoch"
# where epoch E = 1/p. This ensures that the experiment never goes more than 2E trials without a bit
# k = number of ones
# E = expectation value for the number of trials to get a success
    z = 3
    console.log("get asserted epoch list: #{z}, #{n}, #{p}")

    k = p * n
    E = 1 / p
    k_int = Math.round(k)
    E_int = Math.round(E)
    if not (k == k_int and E == E_int)
#      alert("get asserted epoch list: #{n}, #{p}, #{k}, #{k_int}, #{E}, #{E_int}")
      throw "(Internal Error) The values 1/p and p*n must both be integer values."
    k = Math.round(k)
    E = Math.round(E)
    iters = 0
    while iters < 100
      bitlist = []
      for i in [0...k]
        bitlist = bitlist.concat(@get_asserted_list(E, p))
      # Now we need to check to see if we have any adjacent ones

      if @check_for_adjacent(bitlist)
        return bitlist
      iters += 1
    throw "(Internal Error) Excessive loop occured in OddballTrial.get_asserted_epoch_list"

  generate_trial: (num_trials, oddball_rate) ->
#    alert("#{num_trials}, #{oddball_rate}, #{@num_pad}")
    console.log("generate_trial(#{num_trials}, #{oddball_rate})")
    tones_list = (@availableTones[0] for dummy in [0...@num_pad])
    bit_list =  (0 for dummy in [0...@num_pad])
    bit_list = bit_list.concat(@get_asserted_epoch_list(num_trials, oddball_rate))
    bit_list = bit_list.concat([2])
    tones_list = (@availableTones[bit] for bit in bit_list) # Sequence complete tone
#    console.log("generate_trial: tones_list", tones_list)
    @trialTones = tones_list
    console.log("Completed generate_trial")
    @dump()

    return tones_list

  generate_default_trial: ->
    console.log("generate_default_trial(#{@num_trials}, #{@oddball_rate})")
    trial = null
    trial = @generate_trial(@num_trials, @oddball_rate)
    return trial

#experiment = new OddballTrial()
#alert(experiment.attributes)

#module.exports =
#  timeout: 400
#  tones: experiment.generate_default_trial()
#  toneLow: experiment.toneLow
#  toneHigh: experiment.toneHigh
module.exports = OddballTrial