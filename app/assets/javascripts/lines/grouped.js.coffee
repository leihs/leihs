###

Grouped Lines

This script provides functionalities to group an array of lines by date ranges
 
###

class GroupedLines
  
  constructor: (lines, sort_by) ->
    return [] if lines.length is 0
    hash = {}
    (hash[JSON.stringify {start_date: line.start_date, end_date: line.end_date}] ?= []).push(line) for line in lines
    grouped_lines = []
    $.each hash, (key, value) ->
      key_obj = JSON.parse key
      grouped_lines.push {start_date: key_obj.start_date, end_date: key_obj.end_date, lines: value}
    grouped_lines.sort (a,b)->
      
      if moment(a.start_date).toDate() < moment(b.start_date).toDate()
        return false
      else if moment(a.start_date).sod().diff(moment(b.start_date).sod(), "days") == 0
        if moment(a.end_date).toDate() < moment(b.end_date).toDate()
          return false
        else if moment(a.end_date).sod().diff(moment(b.end_date).sod(), "days") == 0
          return false
        else
          return true
      else
        return true 
    return grouped_lines 
    
window.GroupedLines = GroupedLines