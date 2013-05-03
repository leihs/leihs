###

 Acknowledge
 
 This script provides functionalities for the acknowledge order process
 
###

class Acknowledge
  
  @setup: ->
    @setup_purpose()
    @validate_approve_button()
    @setup_add_line()
    @setup_remove_line()
    @update_subtitle()
    @setup_explorative_search()
  
  @setup_remove_line: ->
    $(document).live "after_remove_line", ->
      Acknowledge.update_subtitle()
  
  # TODO: dry with hand over controller
  @remove_lines: (line_elements)->
    for line_element in line_elements
      $(line_element).addClass("removed")
      line_data = $(line_element).tmplItem().data
      if line_data.availability_for_inventory_pool? and line_data.availability_for_inventory_pool.changes?
        line_data.availability_for_inventory_pool.changes = new App.Availability(line_data.availability_for_inventory_pool).changes.withoutLines [line_data]
      Line.remove
        element: line_element
        color: "red"
        callback: ()->
          SelectedLines.update_counter()
          if line_data.availability_for_inventory_pool? 
            HandOver.update_model_availability line_data 
  
  @setup_add_line: ->
    $('#process_helper').bind "ajax:success", (xhr, lines)->
      for line in lines
        Acknowledge.add_line line

  @update_subtitle: -> $(".top .subtitle").html $.tmpl "tmpl/subtitle/acknowledge", {lines_data: $("#order").tmplItem().data.lines}
        
  @add_line: (line)->
    # check if line has just to be added to anothers line's sublines
    matching_line = _.find $(".line"), (l)-> 
      l = $(l).tmplItem().data
      return l.start_date == line.start_date and l.end_date == line.end_date and l.model.id == line.model.id
    if matching_line?
      merged_line = App.Line.mergeByModel [$(matching_line).tmplItem().data, line]
      new_line = $.tmpl "tmpl/line", merged_line
      new_line.find(".select input[type=checkbox]").attr "checked", true
      $(matching_line).replaceWith new_line
      Notification.add_headline
        title: "#{line.model.name}"
        text: _jed("quantity increased by %s", line.quantity)
        type: "success"
    else 
      # add line
      ProcessHelper.allocate_line(line)
      Notification.add_headline
        title: "+ #{Str.sliced_trunc(line.model.name, 36)}"
        text: "#{moment(line.start_date).sod().format(i18n.date.XL)}-#{moment(line.end_date).format(i18n.date.L)}"
        type: "success"
    Acknowledge.update_subtitle()
  
  @update_purpose: (new_purpose_description)->
    $("section.purpose p").html new_purpose_description
    $("#order").tmplItem().data.purpose.description = new_purpose_description
    @setup_purpose()
  
  @setup_purpose: ->
    if $(".indent.purpose").height() > 70
      $(".indent.purpose").addClass("collapsed")
      $(".indent.purpose").after("<div class='showmore'></div>")
    $(".indent.purpose.collapsed").live "click", ->
      $(this).removeClass("collapsed")
      $(this).addClass("expanded")
    $(".indent.purpose.expanded").live "click", ->
      $(this).removeClass("expanded")
      $(this).addClass("collapsed")
  
  @update_order: (order)->
    # reset the order template with the new data
    $("#order").html("")
    $('#order').replaceWith($.tmpl("tmpl/order", order))
    #update the subtitle numbers
    subtitle_text = $("#acknowledge .subtitle").html()
    subtitle_text.replace(/^\d+/, order.quantity)
    subtitle_text.replace(/\s\d+/, " "+App.Line.getMaxRange(order.lines))
    $("#acknowledge .subtitle").html(subtitle_text)
    #restore lines which were selected before re templating
    SelectedLines.restore()
    Acknowledge.update_subtitle()
  
  @validate_approve_button: ->
    if $("#order").find(".lines").length == 0
      Buttons.disable $("#approve.multibutton")
    else
      Buttons.enable $("#approve.multibutton")

  @setup_explorative_search: ->
    $("#process_helper button[type='submit']").on "click", (e)=> 
      if ($("#process_helper #code").val().length == 0)
        new App.ExplorativeSearchDialogController
          modelSelectCallback: ProcessHelper.addModel
          customerId: $("#order").tmplItem().data.user.id
          inventoryPoolId: currentInventoryPool.id
          startDate: moment($("#add_start_date").datepicker("getDate")).format("YYYY-MM-DD")
          endDate: moment($("#add_end_date").datepicker("getDate")).format("YYYY-MM-DD")
  
window.Acknowledge = Acknowledge