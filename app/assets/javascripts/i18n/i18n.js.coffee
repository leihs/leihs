###

Internationalisation

This script provides functionalities for internationalisation in JavaScript.
The default is currently de-CH.
 
###

window.i18n =
  locals: {}
  
  to_s: "de-CH"
  
  # MOMENT.JS is our standard date parser
  date:
    L: "DD.MM.YYYY" 
    XL: "dddd DD.MM.YYYY"
    XXL: "DD.MM.YYYY LT"
    XXXL: "dddd DD.MM.YYYY LT"  
    XS: 'DD.MM.YY'
    
  # jQuery Datepicker has different convetions for formating dates
  datepicker:
    L: "dd.mm.yy"
  
  today: "Heute"
  month: "Monat"
  week: "Woche"
  day: "Tag"
  
  months:
    full: ["Januar", "Februar", 'März', 'April', 'Mai', 'Juni', 'Juli','August', 'September', 'Oktober', 'November', 'Dezember']
    trunc: ['Jan', 'Feb', 'Mar', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez']
    
  days:
    first: 1
    full: ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag']
    trunc: ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa']
  
  time: "H:mm U\\hr"
  
  meridiem :
    AM : 'AM'
    am : 'am'
    PM : 'PM'
    pm : 'pm'
    
  calendar :
    sameDay: "[Heute um] LT"
    sameElse: "L"
    nextDay: '[Morgen um] LT'
    nextWeek: 'dddd [um] LT'
    lastDay: '[Gestern um] LT'
    lastWeek: '[letzten] dddd [um] LT'
   
  relative: 
    future : "in %s",
    past : "vor %s",
    s : "ein paar Sekunden",
    m : "einer Minute",
    mm : "%d Minuten",
    h : "einer Stunde",
    hh : "%d Stunden",
    d : "einem Tag",
    dd : "%d Tagen",
    M : "einem Monat",
    MM : "%d Monaten",
    y : "einem Jahr",
    yy : "%d Jahren"
  
  close: 'schliessen'
  regard_opening_hours: "Öffnungszeiten beachten!"
  closed_at_this_day: "An diesem Tag ist die Ausleihe geschlossen."
  
# set lang for moment js
jQuery ()->
  moment.lang i18n.to_s,
    months : i18n.months.full
    monthsShort : i18n.months.trunc
    weekdays : i18n.days.full
    weekdaysShort : i18n.days.trunc
    longDateFormat :
      LT: i18n.time
      L : i18n.days.L
      LL : i18n.date.XL
      LLL : i18n.date.XXL
      LLLL : i18n.date.XXXL
    meridiem :
      AM : i18n.meridiem.AM
      am : i18n.meridiem.am
      PM : i18n.meridiem.PM
      pm : i18n.meridiem.pm
    calendar :
      sameDay: i18n.calendar.sameDay
      sameElse: i18n.calendar.sameElse
      nextDay: i18n.calendar.nextDay
      nextWeek: i18n.calendar.nextWeek
      lastDay: i18n.calendar.lastDay
      lastWeek: i18n.calendar.lastWeek
    relativeTime :
      future : i18n.relative.future
      past : i18n.relative.past
      s : i18n.relative.s
      m : i18n.relative.m
      mm : i18n.relative.mm
      h : i18n.relative.h
      hh : i18n.relative.hh
      d : i18n.relative.d
      dd : i18n.relative.dd
      M : i18n.relative.M
      MM : i18n.relative.MM
      y : i18n.relative.y
      yy : i18n.relative.yy
    ordinal : (number)->
      return "."
