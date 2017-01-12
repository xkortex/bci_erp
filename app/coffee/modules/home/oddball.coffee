## Programmatically generate the file testparams.coffee


class OddballTrial

  num_trials = 4     # Number of trials to run
  num_pad = 2         # ensure at least num_pad low tones occur first
  time_ms = 400      # Time in ms for each trial
  oddball_rate = 0.25 # This is the rate at which the oddball occurs

  # Tones to be used by the module
  availableTones = ['F4', 'C5', 'C3']  # [lo, hi, end]
  toneLow = availableTones[0]
  toneHigh = availableTones[1]
  toneEnd = availableTones[2]
  # Only first two will be used for the random trials

  get_weighted_bits: (p) ->
      # p is the probability of returning a 1
      r = Math.random()
      if r < p
          return 1
      return 0

  get_asserted_list: (n, p) ->
      # This will produce a list with EXACTLY p percent ones in it. This is so we do not get oddballs with no tones
      k = p * n
      k_int = Math.round(k)
      if not (k == k_int)
        alert("#{k}, #{k_int}")
        throw "(Internal error) The product p*n must be an integer value."

      while True
          bitlist = @get_weighted_bits(p) for dummy in [0...n]
          if sum(bitlist) == k
              return bitlist

  get_asserted_epoch_list: (n, p) ->
      # We want an experimental setup which is random, but not TOO random
      # This ensures that we get a list with exactly p percent ones in it, AND we have one bit per each "epoch"
      # where epoch E = 1/p. This ensures that the experiment never goes more than 2E trials without a bit
      # k = number of ones
      # E = expectation value for the number of trials to get a success
      k = p * n
      E = 1 / p
      k_int = Math.round(k)
      E_int = Math.round(E)
      if not (k == k_int and E == E_int)
          alert("get asserted epoch list: #{n}, #{p}, #{k}, #{k_int}, #{E}, #{E_int}")
          throw "(Internal Error) The values 1/p and p*n must both be integer values."
      k = Math.round(k)
      E = Math.round(E)
      while True
          bitlist = []
          for i in [0...k]
              bitlist += get_asserted_list(E, p)
          # Now we need to check to see if we have any adjacent ones
          bitlist2 = [n for n in bitlist]
          bitlist2.append(bitlist2.pop()) # move first to end
          sumlist = []
          for i in [0...bitlist.length]
            sumlist.append(bitlist[i] + bitlist2[i])
          if 1 == max(sumlist)
              return bitlist

  generate_trial: (num_trials, oddball_rate) ->
#    alert("#{num_trials}, #{oddball_rate}, #{@num_pad}")
    tones_list = [@availableTones[0] for dummy in [0...@num_pad]]
    tones_list += [@availableTones[i] for i in @get_asserted_epoch_list(num_trials, oddball_rate)]
    tones_list += [@availableTones[2]] # Sequence complete tone
    alert(tones_list)
    return tones_list

  generate_default_trial: ->
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