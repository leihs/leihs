###

Take Back

This script provides functionalities for the take back process
 
###

class TakeBack
  
  @setup: ->
    @setup_assign()
    @setup_option_lines()
    @update_subtitle()
    @setup_autocomplete()

  @setup_autocomplete: ->
    autocomplete_data = []
    for line in $(".line")
      line_data = $(line).tmplItem().data
      line_data["label"] = "#{line_data.item.inventory_code}: #{line_data.model.name}"
      autocomplete_data.push line_data
    $("#process_helper input#code").data "autocomplete_data", autocomplete_data
  
  @setup_assign: ->
    $("#process_helper").bind "submit", (event)->
      event.preventDefault
      if $(this).find("#code").val().length > 0
        TakeBack.assign $(this).find("#code").val()
        $(this).find("#code").val("")
        $(this).find("input").autocomplete("close")
      return false
  
  @update_subtitle: -> $(".top .subtitle").html $.tmpl "tmpl/subtitle/take_back", {visits_data: _.map($(".visit"), (visit)-> $(visit).tmplItem().data)}
  
  @setup_option_lines: ->
    $(".option_line .quantity input").live "change keyup", ()->
      line = $(this).closest(".line")
      line.find(".select input").attr("checked", true).trigger("change") # select on human input/interaction
      new_quantity = parseInt($(this).val())
      if new_quantity == $(this).closest(".line").tmplItem().data.quantity
        $(this).closest(".line").removeClass("error")
        $(this).closest(".line").addClass("valid assigned")
      else
        $(this).closest(".line").removeClass("valid assigned")
        $(this).closest(".line").addClass("error")
      # store new quantity
      if isNaN(new_quantity) == false
        $(line).tmplItem().data.returned_quantity = new_quantity
  
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
        text: _jed("could not be assigned for take back")
        type: "error"
      return false 
    $(matched_line).find(".select input").attr("checked", true).trigger("change")
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
      text: _jed("was assigned for take back")
      type: "success"
      
  @open_documents: (contracts)->
    dialog = Dialog.add
      trigger: $("#take_back_button")
      content: $.tmpl("tmpl/dialog/take_back/documents", {contracts: contracts})
      dialogClass: "medium documents"
      dialogId: "print"
    # bind close dialog
    dialog.delegate ".close_dialog", "click", (e)->
      e.stopImmediatePropagation()
      window.location = window.location
    # bind ready action
    dialog.delegate ".ready", "click", (e)->
      # go to daily view
      window.location = "//#{location.host}/backend/inventory_pools/#{currentInventoryPool.id}/"
  
  @update_visits = (data)->
    $('#visits').html($.tmpl("tmpl/visit", data))
    SelectedLines.restore()
    TakeBack.update_subtitle()
    Notification.add_headline
      title: _jed("Saved")
      type: "success"
      
      
window.TakeBack = TakeBack
