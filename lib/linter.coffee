#
# Copyright (c) 2016, Joe Roback <joe.roback@gmail.com>. All Rights Reserved.
#
debug = require './debug'
scope = require './scope'
util = require './util'

module.exports = {
  name: 'Atom-Clang'
  grammarScopes: scope.scopes
  scope: 'file'
  lintOnFly: false

  lint: (editor) ->
    debug.log 'lint', util.getEditorPath editor

    return [] unless atom.config.get 'atom-clang.linterEnabled',  scope: editor.getRootScopeDescriptor()
    return [] unless editor.clang?

    editor.clang.coalescer.reparse()
      .then (diagnostics) ->
        debug.log 'diagnostics', diagnostics
        diagnostics
      .catch util.showError []
}
