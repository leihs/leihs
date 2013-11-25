$.views.tags
  
  interval: (start_date, end_date) -> 
    days = moment(end_date).diff(moment(start_date), "days")+1
    return "#{days} #{_jed(days, _jed('Day'), _jed('Days'))}"