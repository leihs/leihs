###
  
  TimeoutCountdown

###

class window.App.TimeoutCountdown

  constructor: (timeoutMinutes)->
    @timeoutMinutes = timeoutMinutes
    do @refreshTime

  refreshTime: ->
    @minutes = @timeoutMinutes
    @seconds = 0
    do @storeCurrentTimeout

  refresh: ->
    do @refreshTime
    $.get "/borrow/refresh_timeout.html"
    $(@).trigger "timeUpdated"

  start: -> 
    do @updateTime
    @interval = setInterval @updateTime, 1000

  storeCurrentTimeout: (date = new Date())-> 
    localStorage.currentTimeout = date

  sync: ->
    @currentTimeout = moment localStorage.currentTimeout
    @minutes = @timeoutMinutes - 1 - Math.floor(Math.floor(moment().diff(@currentTimeout) / 1000) / 60)
    @seconds = 59 - Math.floor(Math.floor(moment().diff(@currentTimeout) / 1000) % 60)

  timeout: ->
    unless @timedout?
      $.get("/borrow/refresh_timeout.json").done (data)=>
        if moment().diff(moment(data.date).add(@timeoutMinutes, "minutes")) <= 0
          @storeCurrentTimeout moment(data.date).toDate()
        else
          @timedout = true
          clearInterval @interval
          $(@).trigger "timeout"

  toString: ->
    minutesAsString = if String(@minutes).length == 1 then "0#{@minutes}" else String(@minutes)
    secondsAsString = if String(@seconds).length == 1 then "0#{@seconds}" else String(@seconds)
    "#{minutesAsString}:#{secondsAsString}"

  updateTime: =>
    do @sync
    remainingSeconds = moment(@currentTimeout).add("minutes", @timeoutMinutes).diff(moment(), "seconds")
    if remainingSeconds <= 0
      do @timeout
    if @seconds <= 0 and @minutes > 0
      @seconds = 59
      @minutes = @minutes - 1
    else if remainingSeconds > 0
      @seconds = @seconds - 1
    $(@).trigger "timeUpdated"