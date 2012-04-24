###

 Acknowledge
 
 This script provides functionalities for the acknowledge order process
 
###

class Acknowledge
  
  @setup: ->
    @setup_purpose()
    @validate_approve_button()
    @setup_add_line()
  
  @setup_add_line: ->
    $('#process_helper').bind "ajax:success", (xhr, lines)->
      for line in lines
        Acknowledge.add_line line
        
  @add_line: (line_data)->
     # check if line was just increased
    matching_line = Underscore.find $(".line"), (line)-> $(line).tmplItem().data.id == line_data.id
    if matching_line?
      Acknowledge.update_line(matching_line, line_data)
      Notification.add_headline
        title: "#{line_data.model.name}"
        text: "quantity increased to #{line_data.quantity}"
        type: "success"
    else 
      # add line
      ProcessHelper.allocate_line(line_data)
      Notification.add_headline
        title: "+ #{Str.sliced_trunc(line_data.model.name, 36)}"
        text: "#{moment(line_data.start_date).sod().format(i18n.date.XL)}-#{moment(line_data.end_date).format(i18n.date.L)}"
        type: "success"
  
  @update_line = (line_element, line_data)->
    new_line = $.tmpl("tmpl/line", line_data)
    $(new_line).find("input").attr("checked", true) if $(line_element).find(".select input").is(":checked")
    $(line_element).replaceWith new_line
  
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
    subtitle_text.replace(/\s\d+/, " "+new MaxRange(order.lines).value)
    $("#acknowledge .subtitle").html(subtitle_text)
    #restore lines which were selected before re templating
    SelectedLines.restore()
  
  @validate_approve_button: ->
    if $("#order").find(".lines").length == 0
      Buttons.disable $("#approve.multibutton")
    else
      Buttons.enable $("#approve.multibutton")
      
window.Acknowledge = Acknowledge