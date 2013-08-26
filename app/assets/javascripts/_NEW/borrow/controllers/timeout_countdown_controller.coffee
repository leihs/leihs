class window.App.Borrow.TimeoutCountdownController extends Spine.Controller

  elements: 
    "#timeout-countdown-time": "countdownTimeEl"

  constructor: (options)->
    super
    @countdown = new App.TimeoutCountdown(App.Order.TIMEOUT_MINUTES)
    do @validateStart
    do @delegateEvents

  delegateEvents: =>
    $(@countdown).on "timeUpdated", => do @renderTime
    $(@countdown).on "timeout", => do @timeout
    @refreshTarget.on "click", => do @refreshTime
    App.Order.on "refresh", =>
      do @validateStart      
      do @refreshTime
    
  refreshTime: => do @countdown.refresh

  renderTime: => 
    @countdownTimeEl.html @countdown.toString()

  timeout: => document.location = "/borrow/order/timed_out"

  validateStart: =>
    if App.Order.current.lines().all().length != 0
      do @countdown.start
      do @renderTime
      @el.removeClass "hidden"