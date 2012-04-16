###

Notification

This is the notification system.
 
###

jQuery ->
  $(document).ajaxError (event, jqXHR, ajaxSettings, thrownError) ->
    try
      response = JSON.parse jqXHR.responseText
      if typeof response is 'object' and response.error?
        Notification.add_headline
          title: response.error.title
          text: response.error.text
          type: "error"
    catch err
      console.log "error: "+ err

class Notification
  
  @duration = 4000
  
  @queue = []
  
  @add_headline = (options)->
     
    headline = $.tmpl "tmpl/notification/headline", {title: options.title, text: options.text}
    $(headline).addClass(options.type)
    $(headline).hide()
    $("body").append headline
    height = $(headline).height()
    $(headline).height(0)
    $(headline).show()
    $(headline).animate
      height: height
    window.setTimeout ->
      $(headline).animate
        height: 0
      , ->
        $(headline).remove()
    , Notification.duration

window.Notification = Notification