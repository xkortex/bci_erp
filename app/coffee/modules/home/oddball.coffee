## Programmatically generate the file testparams.coffee

# Extending the built-in object, because YOLO
Array::sum = (fn = (x) -> x) ->
  @reduce ((a, b) -> a + fn b), 0

class OddballTrial extends Backbone.Model
  #  constructor: (@dummy)  ->
  #    console.log("Constructor called on OddballTrial")
  defaults:
    stuff: 0
  # Tones to be used by the module


  initialize: (options = {}) ->
    spam = 2
# Only first two will be used for the random trials

  setup: () ->
    console.log("Oddball setup() called")
    # Feels super janky but idk how to do it better
    @num_trials = 8 # Number of trials to run
    @num_pad = 2 # ensure at least num_pad low tones occur first
    @time_ms = 400 # Time in ms for each trial
    @oddball_rate = 0.25 # This is the rate at which the oddball occurs
    @availableTones = ['F4', 'C5', 'C3'] # [lo, hi, end]
    @bar = 55
    @toneLow = @availableTones[0]
    @toneHigh = @availableTones[1]
    @toneEnd = @availableTones[2]

  conveyor: (ary) ->
    # First element goes to end of list. Creates a new object
    ary2 = (ary[n] for n in [1...ary.length])
    console.log("conveyor", ary2)
    ary2.push(ary[0])
    console.log("conveyor", ary2)

    return ary2


  max: (ary) ->
    return ary.reduce (t, s) -> Math.max(t, s)

  sum: (ary) ->
    console.log("sum(array)", ary)

    accu = ary.reduce (t, s)->t + s
    console.log("accu", accu)
    return accu

    #    console.log(ary)
    #    accu = 0 # jesus christ why do I have to do this?
    #    console.log("Summing: #{ary} length: #{ary.length}")
    #    for i in [0...ary.length] # this is safe and i know it works
    #      console.log(Number(ary[i]))
    #      accu = accu + Number(ary[i]) # ffs why do I have to hand-hold this language every step of the way?

  check_for_adjacent: (bitlist) ->
    # Now we need to check to see if we have any adjacent ones
    bitlist2 = @conveyor(bitlist)
#    bitlist2.push(bitlist2.shift()) # move first to end
    console.log("check_for_adjacent: |#{bitlist}|#{bitlist2}|")
    console.log(typeof bitlist, typeof bitlist2, typeof bitlist[0], typeof bitlist2[0])
    console.log(bitlist2[0])
#    ziplist = _.zip(bitlist, bitlist2)
#    console.log("check_for_adjacent (ziplist): |#{ziplist}|")
    sumlist = []
    sumlist.push(bitlist[i]+ bitlist2[i]) for i in [0...bitlist.length]
    console.log("Summing: ", bitlist[i], bitlist2[i]) for i in [0...bitlist.length]

    console.log("check_for_adjacent (sumlist): |#{sumlist}|")

    valmax = @max(sumlist)
    console.log("check_for_adjacent (valmax): |#{valmax}|")

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
    bitlist = []

    bitlist.push(@get_weighted_bits(p)) for i in [0...n]
#    bitlist = [@get_weighted_bits(p) for i in n]
#    console.log("get_weighted_bitlist: |#{bitlist}|")
    return bitlist

  get_asserted_list: (n, p) ->
    console.log("get_asserted_list(#{n}, #{p})")
# This will produce a list with EXACTLY p percent ones in it. This is so we do not get oddballs with no tones
    k = p * n
    k_int = Math.round(k)
    if not (k == k_int)
#      alert("#{k}, #{k_int}")
      throw "(Internal error) The product p*n must be an integer value."

    iters = 0
    while iters < 100
#      bitlist = [@get_weighted_bits(p) for dummy in [0...n]]
      bitlist = @get_weighted_bitlist(n, p)
      console.log("typeof bitlist element: ")
      console.log(typeof 2)
      console.log(typeof bitlist[0])
      bitsum = @sum(bitlist)
      console.log("get_asserted_list Bitsum: |#{bitsum}|")
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
    tones_list = [@availableTones[0] for dummy in [0...@num_pad]]
    console.log("Attempting main epoch routine")
    tones_list += [@availableTones[i] for i in @get_asserted_epoch_list(num_trials, oddball_rate)]
    console.log("Completed main epoch routine")
    return null
    tones_list += [@availableTones[2]] # Sequence complete tone
    console.log(tones_list)
    return tones_list

  generate_default_trial: ->
    @setup()
    console.log("generate_default_trial(#{@num_trials}, #{@oddball_rate})")
    trial = null
    trial = @generate_trial(@num_trials, @oddball_rate)
    @trialTones = trial
    return trial

#experiment = new OddballTrial()
#alert(experiment.attributes)

#module.exports =
#  timeout: 400
#  tones: experiment.generate_default_trial()
#  toneLow: experiment.toneLow
#  toneHigh: experiment.toneHigh
module.exports = OddballTrial