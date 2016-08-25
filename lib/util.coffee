#
# Copyright (c) 2016, Joe Roback <joe.roback@gmail.com>. All Rights Reserved.
#
scope = require './scope'

os = require 'os'
path = require 'path'

# clang needs a file path, so if this is an empty buffer, create a unique temporary file path for the editor
getEditorPath = (editor) ->
  filepath = editor.getPath()
  return if filepath? then filepath else path.resolve os.tmpdir(), "AtomClangBuffer-#{editor.getBuffer().getId()}"

# go through all the open editors that are modified and collect their contents to give to libclang
buildUnsavedFiles = ->
  unsavedFiles = []
  atom.workspace.getTextEditors()
    .filter (editor) ->
      return false unless editor.isModified()
      return false unless editor.clang?
      true
    .forEach (editor) ->
      unsavedFiles.push
        filename: getEditorPath editor
        contents: editor.getText()
  unsavedFiles

# libclang args cannot have spaces in, from a user perspective that is annoying
flags_re = /\s+/

formatFlags = (flags) ->
  formattedFlags = []
  flags
  .forEach (flag) ->
    formattedFlags.push.apply(formattedFlags, flag.split(flags_re))
  formattedFlags

# if an error occurs, show it to the user..
showError = (result) ->
  (err) ->
    console.error err
    atom.notifications.addError "Atom-Clang: #{err.name}", detail: err.stack
    result

module.exports = {
  buildUnsavedFiles
  formatFlags
  getEditorPath
  showError
}
