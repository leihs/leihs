###

ProcessHelper

This script provides functionalities to add/assign items to orders and visits
 
###
   
class ProcessHelper
  
  @setup: ->
    @setup_dates() if $("#process_helper .dates").length
    @setup_submit()
    @setup_timerange_update()
    @update_autocomplete_add()
      
  @setup_dates: ->
    $('#process_helper .dates input').each ->
      date = moment($(this).data("date")).sod()
      $(this).val date.format(i18n.date.L)
      $(this).datepicker
        showOtherMonths: true
        selectOtherMonths: true
      if $(this).hasClass("end")
        $(this).datepicker "option", "minDate", moment($('#process_helper .dates .start').val(), i18n.date.L).sod().toDate()
      else
        $(this).datepicker "option", "minDate", moment().sod().toDate()
      if $(this).hasClass("start")
        $(this).change ()->
          min_date = $(this).datepicker("getDate")
          end_date_element = $(this).closest(".dates").find(".end")
          if moment(end_date_element.val(), i18n.date.L).sod().toDate() < min_date 
            end_date_element.val moment(min_date).sod().add("days",1).format(i18n.date.L)
          end_date_element.datepicker "option", "minDate", min_date
  
  @setup_submit: ->
    $('#process_helper').bind "submit", (event)->
      if $(this).find("#code").val() == ""
        event.preventDefault
        return false
    # clear input field
    $('#process_helper').bind "ajax:beforeSend", (event, jqXHR, settings)-> $(this).find("#code").val("")
  
  @setup_timerange_update: ->
    $(".line .select input, .linegroup .select_group").live "change", (e)->
      setTimeout ->
        start_date = $(".line .select input:checked:first").tmplItem().data.start_date if $(".line .select input:checked:first").length
        end_date = $(".line .select input:checked:last").tmplItem().data.end_date if $(".line .select input:checked:last").length
        start_date = moment().toDate() if start_date == undefined
        end_date = moment().toDate() if end_date == undefined
        ProcessHelper.update_timerange moment(start_date).toDate(), moment(end_date).toDate()
        ProcessHelper.update_autocomplete_add()
      , 100
      
  @open_dialog: (trigger)->
    data = eval trigger.data("ref_for_dialog")
    start_date = $("#add_start_date").datepicker("getDate")
    start_date = start_date.getFullYear()+"-"+(start_date.getMonth()+1)+"-"+start_date.getDate()
    end_date = $("#add_end_date").datepicker("getDate")
    end_date = end_date.getFullYear()+"-"+(end_date.getMonth()+1)+"-"+end_date.getDate()
    ProcessHelper.load_model_data
      url: trigger.attr("href")
      data:
        user_id: data.user.id
        start_date: start_date
        end_date: end_date
        with:
          availability: 1
    
  @update_timerange: (start_date, end_date)->
    $("#process_helper #add_start_date").val(moment(start_date).format(i18n.date.L)).change()
    $("#process_helper #add_end_date").val(moment(end_date).format(i18n.date.L)).change()

  @update_autocomplete_add: ->
    if $("#process_helper .autocomplete[data-url]").length
      $("#process_helper .autocomplete[data-url]").data "autocomplete_with", 
        availability:
          user_id: current_customer
          inventory_pool_id: currentInventoryPool.id
          start_date: moment($("#process_helper #add_start_date").val(), i18n.date.L).format("YYYY-MM-DD")
          end_date: moment($("#process_helper #add_end_date").val(), i18n.date.L).format("YYYY-MM-DD")
      
  @add_through_autocomplete = (selected)->
    id = selected.item.id
    type = selected.item.type
    $("#code").val(id)
    switch type
      when "model"
        $("#code").attr("name", "model_id")
      when "option"
        $("#code").attr("name", "option_id")
      when "template"
        $("#code").attr("name", "model_group_id")
    $("#code").closest("form").submit()
    $("#code").attr("name", "code")
    $("#code").val("")
    $("#code").autocomplete("widget").hide()

  @allocate_line = (line_data)->
    if $("#visits").length
      @allocate_visit line_data, $(".visit")
    else if $("#order").length
      @allocate_linegroup line_data, $(".linegroup")
    # select line if linegroup was selected 
    line = $(".line[data-id=#{line_data.id}]")
    if $(line).closest(".linegroup").find(".select_group").is(":checked")
      $(line).find(".select input").attr("checked", true)
        
  @allocate_visit = (line_data, visits)->
    line_start_date = moment(line_data.start_date).sod()
    line_end_date = moment(line_data.end_date).sod()
    for visit in visits
      visit_date = moment($(visit).tmplItem().data.date).sod()
      if line_start_date.diff(visit_date, "days") < 0
        # set new line before this visit
        $(visit).before $.tmpl("tmpl/visit", { action: line_data.contract.action, date: line_data.start_date, lines: [line_data], user: line_data.contract.user })
        return true
      else if line_start_date.diff(visit_date, "days") == 0
        # set new line inside this visit
        @allocate_linegroup line_data, $(visit).find(".linegroup")
        return true
    if visits.length > 0
      # set new line after the last visit
      $(_.last visits).after $.tmpl("tmpl/visit", { action: line_data.contract.action, date: line_data.start_date, lines: [line_data], user: line_data.contract.user })
    else
      # set new line inside the empty visits container
      $("#visits").append $.tmpl("tmpl/visit", { action: line_data.contract.action, date: line_data.start_date, lines: [line_data], user: line_data.contract.user })
    return true

  @allocate_linegroup = (line_data, linegroups)->
    line_start_date = moment(line_data.start_date).sod()
    line_end_date = moment(line_data.end_date).sod()
    for linegroup in linegroups
      linegroup_start_date = moment($(linegroup).tmplItem().data.start_date).sod()
      linegroup_end_date = moment($(linegroup).tmplItem().data.end_date).sod()
      if line_start_date.diff(linegroup_start_date, "days") < 0 or (line_start_date.diff(linegroup_start_date, "days") == 0 and line_end_date.diff(linegroup_end_date, "days") < 0)
        # set new linegroup before this one
        $(linegroup).closest(".indent").before $.tmpl("tmpl/linegroup", App.Line.groupByDateRanges([line_data]))
        return true
      else if (linegroup_start_date.diff(line_start_date, "days") == 0) and (linegroup_end_date.diff(line_end_date, "days") == 0)
        first_after_line = _.find $(linegroup).find(".lines .line"), (line)-> $(line).tmplItem().data.model.name > line_data.model.name
        if first_after_line?
          $(first_after_line).before($.tmpl("tmpl/line", line_data))
        else
          $(linegroup).find(".lines").append $.tmpl("tmpl/line", line_data)
        return true
    if linegroups.length > 0
      # set new linegroup after the last linegroup
      $(_.last linegroups).closest(".indent").after $.tmpl("tmpl/linegroup", App.Line.groupByDateRanges([line_data]))
    else 
      # set new linegroup inside the order container
      $("#order").append $.tmpl("tmpl/linegroup", App.Line.groupByDateRanges([line_data]))
    return true

window.ProcessHelper = ProcessHelper
