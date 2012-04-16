###

Hand Over

This script provides functionalities for the hand over process
 
###

class HandOver
  
  @setup = ()->
    @setup_assign_inventory_code()
    @setup_hand_over_button()
    @setup_add_item()
  
  @setup_assign_inventory_code = ()->
    # before assign
    $(".item_line .inventory_code form").live "ajax:beforeSend", ()->
      $(this).find("input").attr("disabled", true)
      $(this).append LoadingImage.get()
    $(".item_line .inventory_code form").live "ajax:success", (event, data)->
      $(this).closest(".line").replaceWith $.tmpl("tmpl/line", data)
      # notification
      Notification.add_headline
        title: "Assigned"
        text: "#{data.model.name} to #{data.m}"
        type: "success"
    $(".item_line .inventory_code form").live "ajax:error", ()->
      $(this).find("input").val("")
    $(".item_line .inventory_code form").live "ajax:complete", ->
      $(this).find(".loading").remove()
      $(this).find("input").removeAttr("disabled")
      $(this).closest(".line").removeClass "assigned"
  
  @setup_hand_over_button = ()->
    $("#hand_over_button").on "click", ()->
      SelectionActions.storeSelectedLines()
      
  @setup_hand_over_button = ()->
    $("#hand_over_button").on "click", ()->
      SelectionActions.storeSelectedLines()
      
  @update_visits = (data)->
    $('#visits').replaceWith($.tmpl("tmpl/visits", data))
    SelectionActions.set_target($('#visits'))
    SelectionActions.restoreSelectedLines()
    @update_subtitle()
  
  @setup_add_item: ->
    $('#add_item').bind "ajax:success", (xhr, data)->
      HandOver.add_line data
  
  @add_line: (line_data)->
    line_start_date = moment(line_data.start_date).sod()
    line_end_date = moment(line_data.end_date).sod()
    $(line_as_tmpl).find(".select input").attr("checked", true)
    # notification
    Notification.add_headline
      title: "Added"
      text: "#{line_data.model.name} (#{line_start_date.format(i18n.date.L)} - #{line_end_date.format(i18n.date.L)})"
      type: "success"
    # add template
    for visit in $(".visit")
      visit_date = moment($(visit).tmplItem().data.date).sod()
      if line_start_date.diff(visit_date, "days") < 0 # set new line before this visit
        new_visit = 
          action: line_data.contract.action
          date: line_data.start_date
          lines: [line_data]
          user: line_data.contract.user
        new_visit_tmpl = $.tmpl("tmpl/visit", new_visit)
        $(visit).before new_visit_tmpl
        return true
      else if line_start_date.diff(visit_date, "days") == 0 # set new line inside this visit
        for linegroup in $(visit).find(".linegroup")
          linegroup_start_date = moment($(linegroup).tmplItem().data.start_date).sod()
          linegroup_end_date = moment($(linegroup).tmplItem().data.end_date).sod()
          if linegroup_start_date.diff(line_start_date.toDate(), "days") < 0 # set new linegroup before this one
            new_linegroup_data = new GroupedLines([line_data])
            new_linegroup_tmpl = $.tmpl("tmpl/linegroup", new_linegroup_data)
            $(linegroup).closest(".indent").before new_linegroup_tmpl
            return true
          else if (linegroup_start_date.diff(line_start_date.toDate(), "days") == 0) and (linegroup_end_date.diff(line_end_date.toDate(), "days") == 0)
            line_as_tmpl = $.tmpl("tmpl/line", line_data)
            $(linegroup).find(".lines").append line_as_tmpl
            return true
        # set new linegroup after the last linegroup
        new_linegroup_data = new GroupedLines([line_data])
        new_linegroup_tmpl = $.tmpl("tmpl/linegroup", new_linegroup_data)
        $(visit).find(".linegroup:last").closest(".indent").after new_linegroup_tmpl                
        return true
    # set new line after the last visit
    new_visit = 
      action: line_data.contract.action
      date: line_data.start_date
      lines: [line_data]
      user: line_data.contract.user
    new_visit_tmpl = $.tmpl("tmpl/visit", new_visit)
    $(".visit:last").after new_visit_tmpl
  
  @update_subtitle = ->
    console.log "UPDATE SUBTITLE"
    # var subtitle_text = $("#acknowledge .subtitle").html();
    # subtitle_text.replace(/^\d+/, order.quantity);
    # subtitle_text.replace(/\s\d+/, " "+new MaxRange(order.lines).value);
    # $("#acknowledge .subtitle").html(subtitle_text);
  
window.HandOver = HandOver