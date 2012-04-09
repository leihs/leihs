###

Line

This script provides functionalities for a line
 
###

class Line
  
  @get_problems = (data)->
    problems = []
    problems.push "The model is not available" if data.is_available == false
    return problems
    
window.Line = Line