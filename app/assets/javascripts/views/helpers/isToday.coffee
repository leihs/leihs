$.views.helpers
  
  isToday: (date)-> moment(date).endOf("day").diff(moment().endOf("day"), "days") == 0