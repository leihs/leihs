###

Min Dates

This script provides functionalities to compute the min date of an array of lines
 
###

class MinDate
  
  constructor: (lines) ->
    min_dates = []
    min_dates.push new Date(line.start_date.replace(/-/g, "/")) for line in lines
    @min_date = min_dates.reduce (a,b) -> Math.min(a, b)
    @min_date = new Date(@min_date)
    return @min_date
    
window.MinDate = MinDate