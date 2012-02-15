###

Max Range

This script provides functionalities to compute the max range of an array of lines
 
###

class MaxRange
  
  constructor: (lines) ->
    if lines.length is 0
      @value = 0
      return this
    max_ranges = []
    max_ranges.push ((new Date(line.end_date.replace(/-/g, "/")) - new Date(line.start_date.replace(/-/g, "/"))) / (1000 * 60 * 60 * 24)+1) for line in lines
    @value = Math.round max_ranges.reduce (a,b) -> Math.max(a, b)
    return this
    
window.MaxRange = MaxRange