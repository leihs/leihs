angular.module("filters.dateformat", []).filter "dateformat", ->
  (date, format) ->
    return unless date
    moment(date).sod().format(format)




