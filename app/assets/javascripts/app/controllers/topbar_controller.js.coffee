class TopBarController

  el: "#topbar"
  
  constructor: ->
    @el = $(@el)
    @start_screen_button = {}
    do @delegate_events
    
  delegate_events: =>
    console.log "DELEGATE"
    
window.App.TopBarController = TopBarController
