#
# Copyright (c) 2016, Joe Roback <joe.roback@gmail.com>. All Rights Reserved.
#

log = (area, args...) ->
  console.debug "atom-clang #{area}", args... if atom.inDevMode()

trace = (area, args...) ->
  console.trace "atom-clang #{area}", args... if atom.inDevMode()

module.exports = {
  log
  trace
}
