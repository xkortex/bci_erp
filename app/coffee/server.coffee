
# https://nodejs.org/api/child_process.html
child_process = require('child_process')

# # # # #

class ServerWorker

  # Helper function for spawning generic process
  spawnProcess: (command, args=[]) ->
    spawn = child_process.spawn
    process = spawn(command, args)

    process.stdout.on 'data', (data) =>
      console.log("stdout: #{data}")

    process.stderr.on 'data', (data) =>
      console.log("stderr: #{data}")

    process.on 'close', (code) =>
      console.log("child process exited with code #{code}")

    return true

  # Helper function for invoking python scripts
  invokePython: (script, args=[]) ->
    script = './python/' + script
    processArgs = [script].concat(args)
    return @spawnProcess('python', processArgs)

# # # # #

# Exports as window.global
console.log('Hello from server.coffee!')
window.global.ServerWorker = new ServerWorker()
