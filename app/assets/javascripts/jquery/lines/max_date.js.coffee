###

Max Dates

This script provides functionalities to compute the max date of an array of lines
 
###

class MaxDate
  
  constructor: (lines) ->
    max_dates = []
    max_dates.push new Date(line.end_date.replace(/-/g, "/")) for line in lines
    @max_date = max_dates.reduce (a,b) -> Math.max(a, b)
    @max_date = new Date(@max_date)
    
    return @.max_date
    
window.MaxDate = MaxDate