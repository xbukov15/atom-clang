#
# Copyright (c) 2016, Joe Roback <joe.roback@gmail.com>. All Rights Reserved.
#

# list of supported scopes. setup in array
# for more efficient testing against editor scope

c_scope = 'source.c'
cpp_scope = 'source.cpp'

scopes = [
  c_scope
  cpp_scope
]

getScope = (rootScopeDescriptor) ->
  editorScopes = rootScopeDescriptor.getScopesArray()
  return if editorScopes.length > 0 then editorScopes[0] else null

isCScope = (rootScopeDescriptor) ->
  editorScopes = rootScopeDescriptor.getScopesArray()
  return if editorScopes.length > 0 and editorScopes[0] is c_scope then true else false

isCppScope = (rootScopeDescriptor) ->
  editorScopes = rootScopeDescriptor.getScopesArray()
  return if editorScopes.length > 0 and editorScopes[0] is cpp_scope then true else false

# check whether a given root scope descriptor's first element is one of the supported scopes
isEnabledForScope = (rootScopeDescriptor) ->
  editorScopes = rootScopeDescriptor.getScopesArray()
  return if editorScopes.length > 0 and scopes.indexOf(editorScopes[0]) >= 0 then true else false

# format supported scopes for autocomplete-plus provider api
selectors = ->
  '.' + scopes.join ', .'

module.exports = {
  getScope
  isCScope
  isCppScope
  isEnabledForScope
  selectors
  scopes
}
