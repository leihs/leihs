###

Hand Over

This script provides functionalities for the hand over process
 
###

class HandOver
  
  @option_quantity_change_ajax
  
  @setup = ()->
    @setup_assign_inventory_code()
    @setup_process_helper()
    @update_subtitle()
    @setup_delete()
    @setup_option_quantity_changes()
    @setup_purpose()
    @setup_hand_over_button()
    
  @setup_hand_over_button: ->
    $("#hand_over_button").click (e)->
      selected_item_lines = _.filter $(".line"), (line)-> ($(line).find(".select input").is ":checked") and ($(line).tmplItem().data.type is "item_line")
      _.any(selected_item_lines, (line)-> not $(line).hasClass "assigned")
      if _.any(selected_item_lines, (line)-> not $(line).is ".assigned")
        do e.preventDefault
        do e.stopImmediatePropagation
        Notification.add_headline
          title: _jed("Error")
          text: _jed("you cannot hand out lines with unassigned inventory codes")
          type: "error"
        return false
      else if _.any(selected_item_lines, (line)-> moment($(line).tmplItem().data.start_date).diff(moment(), "days") > 0)
        do e.preventDefault
        do e.stopImmediatePropagation
        Notification.add_headline
          title: _jed("Error")
          text: _jed("you cannot hand out lines wich are starting in the future")
          type: "error"
        return false
    
  @setup_purpose: ->
    $(".dialog .purpose button").live "click", (e)->
      e.preventDefault()
      if $(".dialog .add_purpose:visible").length == 0
        $(this).hide()
        $(".dialog .add_purpose").show()
        $(".dialog .add_purpose #purpose").addClass("focus").focus()
        Dialog.rescale $(".dialog")
      return false
    $(".dialog #purpose").live "blur", (e)->
      # prevent sending spaces
      value = $(this).val()
      $(this).val value.replace(/\s\s+/, " ").replace(/^\s$/, "")
      $(this).blur() if value != $(this).val() and $(this).val().length == 0
    
  @setup_option_quantity_changes: ->
    $(".option_line .quantity input").live "keyup change", ()->
      trigger = $(this)
      new_quantity = parseInt $(this).val()
      if isNaN(new_quantity) == false
        line_data = $(this).closest(".line").tmplItem().data
        HandOver.option_quantity_change_ajax.abort() if HandOver.option_quantity_change_ajax?
        HandOver.option_quantity_change_ajax = $.ajax 
          url: $(this).data("url")
          data:
            format: "json"
            line_ids: [line_data.id]
            quantity: new_quantity  
          dataType: "json"
          type: "POST"
          beforeSend: ->
            $(trigger).next(".loading").remove()
            $(trigger).after LoadingImage.get()
          complete: ->
            $(trigger).next(".loading").remove()
          success: (data)->
            HandOver.update_visits data
          
  @setup_delete: ->
    $(document).live "after_remove_line", ->
      HandOver.update_subtitle()
    
  @assign_through_autocomplete = (element, event)->
    $(event.target).val(element.item.inventory_code)
    $(event.target).closest("form").submit()
  
  @update_subtitle: -> $(".top .subtitle").html $.tmpl "tmpl/subtitle/hand_over", {visits_data: _.map($(".visit"), (visit)-> $(visit).tmplItem().data)}
  
  @setup_assign_inventory_code = ()->
    $(".item_line .inventory_code form").live "ajax:beforeSend", ()->
      $(this).find(".icon").hide()
      $(this).find("input[type=text]").attr("disabled", true)
      $(this).append LoadingImage.get()
      $(this).find("input:focus").blur()
    $(".item_line .inventory_code form").live "ajax:success", (event, data)->
      line = $(this).closest(".line")
      line_checkbox = line.find(".select input[type=checkbox]")
      if $(this).find("input[type=text]").val() == ""
        if line_checkbox.is(":checked")
          line_checkbox.attr("checked", false).trigger("change")
        Notification.add_headline
          title: ""
          text: _jed("The assignment for %s was removed", data.model.name)
          type: "success"
      else
        unless line_checkbox.is(":checked")
          line_checkbox.attr("checked", true).trigger("change")
        Notification.add_headline
          title: "#{data.item.inventory_code}"
          text: _jed("assigned to %s", data.model.name)
          type: "success"
      HandOver.update_line line, data
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
    $(".item_line .inventory_code .clear").live "click", (event)->
      $(this).closest(".inventory_code").find("input[type=text]").val ""
      $(this).closest("form").submit()
      
  @update_visits = (data)->
    $('#visits').html($.tmpl("tmpl/visit", data))
    SelectedLines.restore()
    HandOver.update_subtitle()
    Notification.add_headline
      title: _jed("Saved")
      type: "success"
  
  @setup_process_helper: ->
    $('#process_helper').bind "ajax:success", (xhr, lines)->
      for line in lines
        HandOver.add_line line
  
  @add_line: (line_data)->
    # update availability for the lines with the same model
    HandOver.update_model_availability line_data if line_data.type == "item_line"
    # try to assign first
    matching_line = $(".line[data-id=#{line_data.id}]")
    if matching_line.length
      HandOver.update_line(matching_line, line_data)
      title = if line_data.item? then line_data.item.inventory_code else line_data.model.inventory_code
      Notification.add_headline
        title: "#{title}"
        text: _jed("assigned to %s", line_data.model.name)
        type: "success"
    else 
      # add line
      ProcessHelper.allocate_line(line_data)
      Notification.add_headline
        title: "+ #{Str.sliced_trunc(line_data.model.name, 36)}"
        text: "#{moment(line_data.start_date).sod().format(i18n.date.XL)}-#{moment(line_data.end_date).format(i18n.date.L)}"
        type: "warning"
    HandOver.update_subtitle()
    # select new line
    $(".line[data-id=#{line_data.id}] .select input").attr("checked", true).trigger("change")
  
  @update_model_availability: (line_data)->
    lines_with_the_same_model = Underscore.filter $("#visits .line"), (line)-> 
      ($(line).tmplItem().data.model.id == line_data.model.id) and not $(line).hasClass("removed")
    for line in lines_with_the_same_model
      if not $(line).hasClass("removed") 
        new_line_data = $(line).tmplItem().data 
        new_line_data.availability_for_inventory_pool = line_data.availability_for_inventory_pool
        HandOver.update_line(line, new_line_data)
  
  # TODO: dry with acknowledge controller
  @remove_lines: (line_elements)->
    for line_element in line_elements
      # remove selection
      $(line_element).find(".select input").attr("checked",false).trigger("change")
      $(line_element).addClass("removed")
      line_data = $(line_element).tmplItem().data
      if line_data.availability_for_inventory_pool? and line_data.availability_for_inventory_pool.changes?
        line_data.availability_for_inventory_pool.changes = new App.Availability(line_data.availability_for_inventory_pool).changes.withoutLines([line_data])
      Line.remove
        element: line_element
        color: "red"
        callback: ()->
          SelectedLines.update_counter()
          if line_data.availability_for_inventory_pool? 
            HandOver.update_model_availability line_data 
  
  @update_line: (line_element, line_data)->
    new_line = $.tmpl("tmpl/line", line_data)
    $(line_element).replaceWith new_line
    $(new_line).find("input").attr("checked", true).trigger("change") if $(line_element).find(".select input").is(":checked")
    
  @open_documents: (contract)->
    dialog = Dialog.add
      trigger: $("#hand_over_button")
      content: $.tmpl("tmpl/dialog/hand_over/documents", {contract: contract})
      dialogClass: "medium documents"
      dialogId: "print"
      dialog_ready: -> Print.print()
    # bind close dialog
    dialog.delegate ".close_dialog", "click", (e)->
      e.stopImmediatePropagation()
      window.location = window.location
    # bind ready action
    dialog.delegate ".ready", "click", (e)->
      # go to daily view
      window.location = "http://#{location.host}/backend/inventory_pools/#{currentInventoryPool.id}/"

  @reduce_quantity: (lines_data)-> _.reduce(lines_data, ((mem, ele) -> mem+ele.quantity), 0)

  @any_missing_purpose: (lines)->
    _.any lines, (line)->
      not line.purpose?

  @data_for_user_swap: ->
    lines: SelectedLines.lines_data
    user: Line.get_user SelectedLines.lines_data[0]
    type: "contract"

window.HandOver = HandOver