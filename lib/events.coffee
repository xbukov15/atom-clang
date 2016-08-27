#
# Copyright (c) 2016, Joe Roback <joe.roback@gmail.com>. All Rights Reserved.
#
debug = require './debug'
scope = require './scope'
util = require './util'

{CompositeDisposable} = require 'atom'
{ClangTranslationUnit} = require('bindings') 'clang.node'
{ParseCoalescer} = require './parsecoalescer'

disposables = null

observeEditors = ->
  atom.workspace.observeTextEditors (editor) ->

    # perform a full translation unit parse
    parse = ->
      debug.log 'parse', editor.clang, util.buildUnsavedFiles(), util.getEditorPath editor
      return Promise.resolve() unless editor.clang?
      editor.clang.translationUnit.parse true, editor.clang.flags, util.buildUnsavedFiles()

    # reparse translation unit
    reparse = ->
      debug.log 'reparse', editor.clang, util.buildUnsavedFiles(), util.getEditorPath editor
      return Promise.resolve() unless editor.clang?
      editor.clang.translationUnit.parse false, editor.clang.flags, util.buildUnsavedFiles()

    # attempt to load clang into editor, only loads if enabled for scope/grammar
    load = ->
      return unless scope.isEnabledForScope editor.getRootScopeDescriptor()
      debug.log 'load', util.getEditorPath editor

      # add clang state to editor. seems like the most convenient and efficient way...
      editor.clang =
        flags: null
        coalescer: null
        translationUnit: null
        subscriptions: null

      # this queue ensures us that only one parse/reparse is ever outstanding
      editor.clang.coalescer = new ParseCoalescer parse, reparse

      # create native libclang translation unit object for parsing/completions
      editor.clang.translationUnit = new ClangTranslationUnit util.getEditorPath editor

      # register for config subscriptions
      editor.clang.subscriptions = new CompositeDisposable()

      #
      # only enable onDidChange for scope, if grammar changes, we will unload/load again...
      # since we are changing compilation flags, it needs a full parse
      #
      # note: order here is important because onDidStopChanging will trigger when loading
      # a file into a editor, which calls reparse and we have to make sure we have called
      # parse at least one prior
      #

      if scope.isCScope editor.getRootScopeDescriptor()
        editor.clang.subscriptions.add atom.config.observe 'atom-clang.defaultCFlags', (flags) ->
          flags.push '-xc'
          flags.push '-Wno-pragma-once-outside-header'
          editor.clang.flags = util.formatFlags flags
          editor.clang.coalescer.parse().catch util.showError()
      else if scope.isCppScope editor.getRootScopeDescriptor()
        editor.clang.subscriptions.add atom.config.observe 'atom-clang.defaultCXXFlags', (flags) ->
          flags.push '-xc++'
          flags.push '-Wno-pragma-once-outside-header'
          editor.clang.flags = util.formatFlags flags
          editor.clang.coalescer.parse().catch util.showError()
      else
        editorScope = scope.getScope editor.getRootScopeDescriptor()
        util.showError() new Error "Unable to match file type: #{editorScope}"

    # unload clang from editor
    unload = ->
      return unless editor.clang?
      debug.log 'unload', util.getEditorPath editor

      #
      # dispose of clang properties
      #

      if editor.clang.translationUnit?
        editor.clang.translationUnit.dispose()

      if editor.clang.subscriptions?
        editor.clang.subscriptions.dispose()

      # fully remove object from editor
      delete editor.clang

    #
    # register observers for editor
    #
    # the main idea here is to load the least amount possible, as we really
    # only want to pollute editor objects for grammars we support: C/C++
    #

    editorDisposables = new CompositeDisposable()

    # when the grammar changes, attempt to load, this is the main entry point when a file is opened
    editorDisposables.add editor.observeGrammar ->
      debug.log 'observeGrammar', util.getEditorPath editor
      unload()
      load()

    # remove all observers, dispose of atom-clang state
    editorDisposables.add editor.onDidDestroy ->
      debug.log 'onDidDestroy', util.getEditorPath editor
      editorDisposables.dispose()
      unload()

    # if the path changes, load again, disposing old state
    editorDisposables.add editor.onDidChangePath ->
      debug.log 'onDidChangePath', util.getEditorPath editor
      unload()
      load()

activate = ->
  disposables = new CompositeDisposable()
  disposables.add observeEditors()

deactivate = ->
  disposables.dispose()
  disposables = null

module.exports = {
  activate
  deactivate
}
