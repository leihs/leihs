###

Take Back

This script provides functionalities for the take back process
 
###

class TakeBack
  
  @setup: ->
    @setup_assign()
    @setup_option_lines()
  
  @setup_assign: ->
    $("#process_helper").bind "submit", (event)->
      event.preventDefault
      if $(this).find("#code").val().length > 0
        TakeBack.assign $(this).find("#code").val()    
        $(this).find("#code").val("")    
      return false
  
  @setup_option_lines: ->
    $(".option_line .quantity input").live "change keyup", ()->
      if parseInt($(this).val()) == $(this).closest(".line").tmplItem().data.quantity
        $(this).closest(".line").removeClass("error")
        $(this).closest(".line").addClass("valid assigned")
      else
        $(this).closest(".line").removeClass("valid assigned")
        $(this).closest(".line").addClass("error")
  
  @assign_through_autocomplete: (element)->
    if element.item.model.inventory_code?
      TakeBack.assign element.item.model.inventory_code
    else
      TakeBack.assign element.item.item.inventory_code
    
  @assign: (code)->
    matched_line = _.find $(".line"), (line)->
      return ($(line).tmplItem().data.model.inventory_code.toLowerCase() == code.toLowerCase()) if $(line).tmplItem().data.model.inventory_code? 
      return ($(line).tmplItem().data.item.inventory_code.toLowerCase() == code.toLowerCase()) if $(line).tmplItem().data.item.inventory_code?
    if not matched_line?
      Notification.add_headline
        title: "#{code}"
        text: "could not be assigned for take back"
        type: "error"
      return false 
    $(matched_line).find(".select input").attr("checked", true).change()
    switch $(matched_line).tmplItem().data.type
      when "item_line"
        $(matched_line).addClass "assigned valid"
      when "option_line"
        if $(matched_line).find(".quantity input").val().length == 0
          $(matched_line).find(".quantity input").val(1)
        else
          $(matched_line).find(".quantity input").val (parseInt($(matched_line).find(".quantity input").val())+1)
        $(matched_line).find(".quantity input").change()
    Notification.add_headline
      title: "#{code}"
      text: "was assigned for take back"
      type: "success"
  
window.TakeBack = TakeBack