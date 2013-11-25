$.views.tags
  
  diffDates: (firstDate, secondDate) ->
    if moment(secondDate).startOf("day").diff(moment(firstDate).startOf("day"), "days") < 1
      _jed("Today")
    else
      moment(firstDate).startOf("day").from(moment(secondDate).startOf("day"))

  diffDatesInDays: (firstDate, secondDate) -> 
    days = moment(secondDate).endOf("day").diff(moment(firstDate).startOf("day"), "days") + 1
    "#{days} #{_jed('Days', 'Day', days)}"

  diffToday: (date) ->
    if moment().startOf("day").diff(moment(date).startOf("day"), "days") < 1
      _jed("Today")
    else
      moment(date).startOf("day").from(moment().startOf("day"))

  todayOrDate: (date) ->
    if moment().startOf("day").diff(moment(date).startOf("day"), "days") < 1
      _jed("Today")
    else
      moment(date).startOf("day").from(moment().startOf("day"))

  date: (date)-> moment(date).format(i18n.date.L)

  day: (date)-> moment(date).format("dddd")

  dateAndTime: (date) ->
    "#{$.views.tags.diffToday.render(date)} #{moment(date).format("LT")}"