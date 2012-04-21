###

Hand Over

This script provides functionalities for the hand over process
 
###

class HandOver
  
  @setup = ()->
    @setup_assign_inventory_code()
    @setup_hand_over_button()
    @setup_add_item()
    
  @assign_through_autocomplete = (element, event)->
    $(event.target).val(element.item.inventory_code)
    $(event.target).closest("form").submit()
  
  @setup_assign_inventory_code = ()->
    $(".item_line .inventory_code form").live "ajax:beforeSend", ()->
      $(this).find(".icon").hide()
      $(this).find("input[type=text]").attr("disabled", true)
      $(this).append LoadingImage.get()
      $(this).find("input:focus").blur()
    $(".item_line .inventory_code form").live "ajax:success", (event, data)->
      HandOver.update_line $(this).closest(".line"), data
      # notification
      Notification.add_headline
        title: "#{data.item.inventory_code}"
        text: "assigned to #{data.model.name}"
        type: "success"
    $(".item_line .inventory_code form").live "ajax:error", ()->
      $(this).find("input[type=text]").val("")
    $(".item_line .inventory_code form").live "ajax:complete", ->
      $(this).find(".loading").remove()
      $(this).find(".icon").show()
      $(this).find("input[type=text]").removeAttr("disabled")
      $(this).find("input[type=text]").autocomplete("destroy")
      $(this).closest(".line").removeClass "assigned"
    $(".item_line .inventory_code input").live "focus", (event)->
      $(this).data("value_on_focus", $(this).val())
    $(".item_line .inventory_code input").live "blur", (event)->
      if $(this).val() != $(this).data("value_on_focus")
        trigger = $(this)
        setTimeout ()->
          if $(trigger).siblings(".loading:visible").length == 0
            $(trigger).closest("form").submit()
        ,100
    $(".item_line .inventory_code input").live "keyup", (event)->
      if $(this).val() == "" and $(this).data("value_on_focus") != ""
        $(this).closest("form").submit()
        $(this).focus()
  
  @setup_hand_over_button = ()->
    $("#hand_over_button").on "click", ()->
      SelectionActions.storeSelectedLines()
      
  @update_visits = (data)->
    $('#visits').replaceWith($.tmpl("tmpl/visits", data))
    SelectionActions.set_target($('#visits'))
    SelectionActions.restoreSelectedLines()
    @update_subtitle()
  
  @setup_add_item: ->
    $('#add_item').bind "ajax:success", (xhr, lines)->
      for line in lines
        HandOver.add_line line
  
  @add_line: (line_data)->
    # update availability for the lines with the same model
    lines_with_the_same_model = Underscore.filter $("#visits .line"), (line)-> $(line).tmplItem().data.model.id == line_data.model.id
    for line in lines_with_the_same_model 
      new_line_data = $(line).tmplItem().data 
      new_line_data.availability_for_inventory_pool = line_data.availability_for_inventory_pool
      HandOver.update_line(line, new_line_data)
    # try to assign first
    matching_line = Underscore.find $("#visits .line"), (line)-> $(line).tmplItem().data.id == line_data.id
    if matching_line?
      HandOver.update_line(matching_line, line_data)
      title = if line_data.item? then line_data.item.inventory_code else line_data.model.inventory_code
      Notification.add_headline
        title: "#{title}"
        text: "assigned to #{line_data.model.name}"
        type: "success"
    else 
      # add line
      AddItem.allocate_line(line_data)
      Notification.add_headline
        title: "+ #{Str.sliced_trunc(line_data.model.name, 36)}"
        text: "#{moment(line_data.start_date).sod().format(i18n.date.XL)}-#{moment(line_data.end_date).format(i18n.date.L)}"
        type: "success"
  
  @update_line = (line_element, line_data)->
    new_line = $.tmpl("tmpl/line", line_data)
    $(new_line).find("input").attr("checked", true) if $(line_element).find(".select input").is(":checked")
      
    $(line_element).replaceWith new_line
  
  @update_subtitle = ->
    console.log "UPDATE SUBTITLE"
    # var subtitle_text = $("#acknowledge .subtitle").html();
    # subtitle_text.replace(/^\d+/, order.quantity);
    # subtitle_text.replace(/\s\d+/, " "+new MaxRange(order.lines).value);
    # $("#acknowledge .subtitle").html(subtitle_text);
  
window.HandOver = HandOver