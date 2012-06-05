class InventoryController

  el: "#inventory .list"
  
  constructor: ->
    @el = $(@el)
    do @render
    do @plugin
    
  render: -> 
    console.log "Render"
    
  plugin: ->
    do ListSearch.setup
    @el.find(".navigation select").custom_select
      postfix: "<div class='icon arrow down'></div>"
      text_handler: (text)-> Str.sliced_trunc(text, 22)
    
  @fetch: (options)->
    console.log "fetch"
    @el.find(".toggle[data-toggle_target]").expandable_line()

window.App.InventoryController = InventoryController
