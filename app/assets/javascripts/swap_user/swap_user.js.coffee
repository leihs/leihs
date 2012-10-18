###

SwapUser

This script provides functionalities to swap user for a complete order or selected hand over lines
 
###
   
class SwapUser

  @setup: =>
    @el = $(".swap_user .dialog")
    do @delegateEvents

  @delegateEvents: =>
    @el.on "click", ".user.line .clear", => do @removeSetUser
      
  @removeSetUser: =>
    @el.find(".button[type=submit]").attr "disabled", true
    @el.find(".new .user.line").remove()
    @el.find(".new").removeClass "set"
    @el.find(".new input").focus()

  @setNewUser: (autocompleteItem)=>
    @el.find(".button[type=submit]").attr "disabled", false
    user = autocompleteItem.item
    @el.find(".autocomplete").blur()
    @el.find(".new").addClass("set")
    tmpl = $.tmpl "tmpl/dialog/swap_user/user_line", user
    @el.find(".new").append tmpl

window.SwapUser = SwapUser