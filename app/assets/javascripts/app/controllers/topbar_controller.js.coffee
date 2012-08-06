class TopBarController

  el: "#topbar"
  
  constructor: ->
    @el = $(@el)
    @start_screen_button = @el.find(".user .start_screen_setter")
    do @delegate_events
    
  delegate_events: =>
    @start_screen_button.on "click", @set_start_screen
  
  set_start_screen: (e)=>
    do e.preventDefault
    $.ajax
      url: "/backend/users/#{current_user.id}/set_start_screen"
      type: "POST"
      data: 
        path: window.location.pathname + window.location.search + window.location.hash
      success: =>
        @start_screen_button.closest("li").addClass("active")
        @start_screen_button.html $.tmpl("app/views/application/topbar/_active_start_screen")
    
window.App.TopBarController = TopBarController
