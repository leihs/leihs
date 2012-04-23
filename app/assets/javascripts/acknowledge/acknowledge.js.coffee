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
    $('#add_item').bind "ajax:success", (xhr, lines)->
      for line in lines
        Acknowledge.add_line line
        
  @add_line: (line_data)->
    AddItem.allocate_line(line_data)
    Notification.add_headline
      title: "+ #{Str.sliced_trunc(line_data.model.name, 36)}"
      text: "#{moment(line_data.start_date).sod().format(i18n.date.XL)}-#{moment(line_data.end_date).format(i18n.date.L)}"
      type: "success"
  
  @add_new_line: (line_data)->
    line_start_date = moment(line_data.start_date).sod()
    line_end_date = moment(line_data.end_date).sod()
    line_as_tmpl = $.tmpl("tmpl/line", line_data)
    # allocate
    for linegroup in $(".linegroup")
      linegroup_start_date = moment($(linegroup).tmplItem().data.start_date).sod()
      linegroup_end_date = moment($(linegroup).tmplItem().data.end_date).sod()
      if line_start_date.diff(linegroup_start_date, "days") < 0 or (line_start_date.diff(linegroup_start_date, "days") == 0 and line_end_date.diff(linegroup_end_date, "days") < 0)
        # set new linegroup before this one
        new_linegroup_data = new GroupedLines([line_data])
        new_linegroup_tmpl = $.tmpl("tmpl/linegroup", new_linegroup_data)
        $(linegroup).closest(".indent").before new_linegroup_tmpl
        return true
      else if (linegroup_start_date.diff(line_start_date, "days") == 0)
        $(linegroup).find(".lines").append line_as_tmpl
        return true
    # set new linegroup after the last linegroup
    new_linegroup_data = new GroupedLines([line_data])
    new_linegroup_tmpl = $.tmpl("tmpl/linegroup", new_linegroup_data)
    $(".linegroup:last").closest(".indent").after new_linegroup_tmpl 
    return true
  
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