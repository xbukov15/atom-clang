#
# Copyright (c) 2016, Joe Roback <joe.roback@gmail.com>. All Rights Reserved.
#

log = (area, args...) ->
  console.debug "atom-clang #{area}", args... if atom.inDevMode()

result = (area, result) ->
  console.debug "atom-clang #{area}", result if atom.inDevMode()
  result

module.exports = {
  log
  result
}
