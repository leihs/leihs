angular.module("filters", []).filter "truncate", ->
  (text, length, end) ->
    length = 10  if isNaN(length)
    end = "..."  if end is `undefined`
    if text.length <= length or text.length - end.length <= length
      text
    else
      String(text).substring(0, length - end.length) + end
