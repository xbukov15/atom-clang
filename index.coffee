commands = require './lib/commands'
config = require './lib/config'
events = require './lib/events'
linter = require './lib/linter'
provider = require './lib/provider'

{clangVersion} = require('bindings') 'clang.node'

activate = ->
  require 'atom-package-deps'
    .install 'atom-clang'
    .then ->
      console.log 'atom-clang', clangVersion()
      commands.activate()
      events.activate()

deactivate = ->
  events.deactivate()
  commands.deactivate()

module.exports = {
  config
  provide: -> provider
  provideLinter: -> linter
  activate
  deactivate
}
