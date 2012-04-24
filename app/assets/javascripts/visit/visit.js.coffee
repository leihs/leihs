###

Visit

This script provides functionalities for visits
 
###

class Visit
  
  @get_future: (visits)->
    Underscore.filter visits, (visit) -> moment().sod().diff(moment(visit.date).sod(), "days") < 0
  
  @get_today: (visits)->
    Underscore.filter visits, (visit) -> moment().sod().diff(moment(visit.date).sod(), "days") == 0
  
  @get_past: (visits)->
    Underscore.filter visits, (visit) -> moment().sod().diff(moment(visit.date).sod(), "days") > 0
  
window.Visit = Visit