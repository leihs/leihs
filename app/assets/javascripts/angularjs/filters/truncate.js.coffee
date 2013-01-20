# FIXME how to include all filter modules at once? # http://www.itaware.eu/2012/10/19/angularjs-modules-and-services/
angular.module("filters", ['filters.dateformat', 'filters.truncate'])

angular.module("filters.truncate", []).filter "truncate", ->
  (text, length, end) ->
    return unless text
    length = 10  if isNaN(length)
    end = "..."  if end is `undefined`
    if text.length <= length or text.length - end.length <= length
      text
    else
      String(text).substring(0, length - end.length) + end
