fs = require 'fs'
{spawn, exec} = require 'child_process'

# Run a CoffeeScript through our node/coffee interpreter.
run = (args) ->
  proc = spawn 'coffee', args
  proc.stderr.on 'data', (buffer) -> console.log buffer.toString()
  proc.on        'exit', (status) -> process.exit(1) if status != 0

task 'build', 'compile CoffeeScripts into JavaScripts', ->
  files = fs.readdirSync 'src/twitter'
  files = ('src/twitter/' + file for file in files when file.match(/\.coffee$/))
  run ['-c', '-o', 'lib/twitter'].concat(files)
