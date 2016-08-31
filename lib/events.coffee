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

# clang needs a file path, so if this is an empty buffer, create a unique temporary file path for the buffer
getEditorPath = (editor) ->
  filepath = editor.getPath()
  return if filepath? then filepath else path.resolve os.tmpdir(), "AtomClangBuffer-#{editor.getBuffer().getId()}"

# libclang args cannot have spaces in, from a user perspective that is annoying, correct it here
flags_re = /\s+/

formatFlags = (flags) ->
  formattedFlags = []
  flags.forEach (flag) ->
    formattedFlags.push.apply(formattedFlags, flag.split(flags_re))
  formattedFlags

# go through all the open buffers that are modified and collect their contents to give to libclang
buildUnsavedFiles = ->
  unsavedFiles = []
  buffers = new Set()
  atom.workspace.getTextEditors().forEach (editor) ->
    if editor.clang? and editor.isModified()
      id = editor.getBuffer().id
      if not buffers.has(id)
        buffers.add id
        unsavedFiles.push
          filename: getEditorPath editor
          contents: editor.getText()
  unsavedFiles

#
# the general idea is we start a clang translation unit per editor
# if the same underlying buffer is split between panes, there will be
# multiple translation units. this is because Atom allows the user to
# change scopes/grammars on a per editor/pane, so a header parsed with
# C grammar will have different arguments to clang then C++
#

observeEditors = ->
  atom.workspace.observeTextEditors (editor) ->
    # perform a full translation unit parse
    parse = ->
      debug.log 'parse', editor.clang, buildUnsavedFiles(), getEditorPath editor
      return Promise.resolve([]) unless editor.clang?
      editor.clang.translationUnit.parse true, editor.clang.flags, buildUnsavedFiles()

    # reparse translation unit
    reparse = ->
      debug.log 'reparse', editor.clang, buildUnsavedFiles(), getEditorPath editor
      return Promise.resolve([]) unless editor.clang?
      editor.clang.translationUnit.parse false, editor.clang.flags, buildUnsavedFiles()

    load = ->
      return unless scope.isEnabledForScope editor.getRootScopeDescriptor()
      debug.log 'load', editor
      console.assert not editor.clang?, editor

      editor.clang =
        flags: null
        translationUnit: null
        coalescer: null
        completions: null
        subscriptions: null

      # create native libclang translation unit object for parsing/completions
      editor.clang.translationUnit = new ClangTranslationUnit getEditorPath editor

      # this queue ensures us that only one parse/reparse is ever outstanding
      editor.clang.coalescer = new ParseCoalescer parse, reparse

      editor.clang.completions = (deprecated, prefix, line, column) ->
        editor.clang.translationUnit.completions \
          deprecated,
          prefix,
          getEditorPath(editor),
          line,
          column,
          buildUnsavedFiles()

      # register for config subscriptions
      editor.clang.subscriptions = new CompositeDisposable()

      # if the path changes, load again, disposing old state
      editor.clang.subscriptions.add editor.onDidChangePath ->
        debug.log 'onDidChangePath', editor
        unload()
        load()

      # if we save, we need to reparse all other clang buffers
      # clang_codeCompleteAt() will not reparse another translation unit
      # because another one was saved, even if that file was a header and
      # and was a dependency of the translation unit it is trying to provide
      # completions for. if files are modified outside Atom, undefined results
      # will happen, best case, is wrong completion data is returned.
      editor.clang.subscriptions.add editor.onDidSave ->
        debug.log 'onDidSave', editor
        atom.workspace.getTextEditors().forEach (other) ->
          if other.clang?
            other.clang.coalescer.reparse().catch util.showError []

      # setup clang flags based on scope/grammar, listen for config changes
      # if the grammar changes, the editor observer will fully unload and re-load
      if scope.isCScope editor.getRootScopeDescriptor()
        editor.clang.subscriptions.add atom.config.observe 'atom-clang.defaultCFlags', (flags) ->
          flags.push '-xc'
          flags.push '-Wno-pragma-once-outside-header'
          editor.clang.flags = formatFlags flags
          editor.clang.coalescer.parse().catch util.showError()
      else if scope.isCppScope editor.getRootScopeDescriptor()
        editor.clang.subscriptions.add atom.config.observe 'atom-clang.defaultCXXFlags', (flags) ->
          flags.push '-xc++'
          flags.push '-Wno-pragma-once-outside-header'
          editor.clang.flags = formatFlags flags
          editor.clang.coalescer.parse().catch util.showError()
      else
        editorScope = scope.getScope editor.getRootScopeDescriptor()
        util.showError() new Error "Unable to match file type: #{editorScope}"

    unload = ->
      return unless editor.clang?
      debug.log 'unload', editor

      # dispose of clang property
      editor.clang.subscriptions.dispose()
      editor.clang.translationUnit.dispose()
      delete editor.clang

    #
    # register observers for editor
    #
    # the main idea here is to load the least amount possible, as we really
    # only want to pollute editor/buffer objects for grammars we support, i.e. C/C++
    #

    # subscriptions to grammar changes and editor destroy
    editorDisposables = new CompositeDisposable()

    # when the grammar changes, attempt to load, this is the main entry point when a file is opened
    editorDisposables.add editor.observeGrammar ->
      debug.log 'observeGrammar', editor
      unload()
      load()

    # remove all observers, dispose of atom-clang state
    editorDisposables.add editor.onDidDestroy ->
      debug.log 'onDidDestroy', editor
      editorDisposables.dispose()
      editorDisposables = null
      unload()

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
