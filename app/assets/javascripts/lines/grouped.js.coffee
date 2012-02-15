###

Grouped Lines

This script provides functionalities to group an array of lines by date ranges
 
###

class GroupedLines
  
  constructor: (lines) ->
    return [] if lines.length is 0
    hash = {}
    (hash[JSON.stringify {start_date: line.start_date, end_date: line.end_date}] ?= []).push(line) for line in lines
    grouped_lines = []
    $.each hash, (key, value) ->
      key_obj = JSON.parse key
      grouped_lines.push {start_date: key_obj.start_date, end_date: key_obj.end_date, lines: value}
    return grouped_lines 
    
window.GroupedLines = GroupedLines