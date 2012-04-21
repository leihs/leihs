###

Add Item 

This script provides functionalities to add items to orders and visits
 
###
   
class AddItem
  
  @setup: ->
    @setup_datepicker_locals()
    @setup_dates()
    @setup_submit()
    @setup_timerange_update()
  
  @setup_datepicker_locals: ->
    $.datepicker.setDefaults
      closeText: i18n.close
      prevText: '&lt;'
      nextText: '&gt;'
      currentText: i18n.today
      monthNames: i18n.months.full
      monthNamesShort: i18n.months.trunc
      dayNames: i18n.days.full
      dayNamesShort: i18n.days.trunc
      dayNamesMin: i18n.days.trunc
      weekHeader: 'Wo'
      dateFormat: i18n.datepicker.L
      firstDay: i18n.days.first
      isRTL: false
      showMonthAfterYear: false
      yearSuffix: ''
      
  @setup_dates: ->
    $('#add_item .dates input').each ->
      date = moment($(this).data("date")).sod()
      $(this).val date.format(i18n.date.L)
      $(this).datepicker
        showOtherMonths: true
        selectOtherMonths: true
      if $(this).hasClass("end")
        $(this).datepicker "option", "minDate", moment($('#add_item .dates .start').val(), i18n.date.L).sod().toDate()
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
    $('#add_item').bind "submit", (event)->
      if $(this).find("#quick_add").val() == ""
        event.preventDefault
        return false
    $('#add_item').bind "ajax:beforeSend", (event, jqXHR, settings)->
       # add selected line ids
      if SelectionActions? and SelectionActions.selected_lines? and SelectionActions.selected_lines.length
        line_ids = Underscore.map(SelectionActions.selected_lines, (line)-> line.id)
        for line_id in line_ids
          settings.data += "&line_ids[]="+line_id
      # clear input field
      $(this).find("#quick_add").val("")
  
  @setup_timerange_update: ->
    $(".line .select input, .linegroup .select_group").live "change", ->
      setTimeout ->
        start_date = $(".line .select input:checked:first").tmplItem().data.start_date
        end_date = $(".line .select input:checked:last").tmplItem().data.end_date
        start_date = moment().toDate() if start_date == undefined
        end_date = moment().toDate() if end_date == undefined
        AddItem.update_timerange moment(start_date).toDate(), moment(end_date).toDate()
      , 100
      
  @open_dialog: (trigger)->
    data = eval trigger.data("ref_for_dialog")
    start_date = $("#add_start_date").datepicker("getDate")
    start_date = start_date.getFullYear()+"-"+(start_date.getMonth()+1)+"-"+start_date.getDate()
    end_date = $("#add_end_date").datepicker("getDate")
    end_date = end_date.getFullYear()+"-"+(end_date.getMonth()+1)+"-"+end_date.getDate()
    AddItem.load_model_data
      url: trigger.attr("href")
      data:
        user_id: data.user.id
        start_date: start_date
        end_date: end_date
        with:
          availability: 1
   
  @load_model_data: ()->
    ajax_options = arguments[0]
    $.extend true, ajax_options, data: format:"json"
    $.extend true, ajax_options, success: AddItem.setup_models
    $.ajax ajax_options
    
  @setup_models: (data)->
    $(".ui-dialog.add_item img.loading").remove()
    $(".ui-dialog.add_item .models.list").append $.tmpl "tmpl/line/add_item/model", data
    Dialog.rescale($(".add_item .dialog"))
    $(".ui-dialog.add_item .models.list").removeClass("invisible").addClass("visible")
    
  @update_timerange: (start_date, end_date)->
    $("#add_item #add_start_date").val(moment(start_date).format(i18n.date.L)).change()
    $("#add_item #add_end_date").val(moment(end_date).format(i18n.date.L)).change()
      
  @through_autocomplete = (element)->
    id = element.item.id
    type = element.item.type
    $("#quick_add").val(id)
    switch type
      when "model"
        $("#quick_add").attr("name", "model_id")
      when "option"
        $("#quick_add").attr("name", "option_id")
      when "template"
        $("#quick_add").attr("name", "model_group_id")
    $("#quick_add").closest("form").submit()
    $("#quick_add").attr("name", "code")
    $("#quick_add").val("")
    $("#quick_add").autocomplete("widget").hide()
   
  @allocate_line = (line_data)->
    if $(".visit").length
      @allocate_visit line_data, $(".visit")
    else if $(".linegroup").length
      @allocate_linegroup line_data, $(".linegroup")
    # select line if linegroup was selected 
    line = _.find $(".line"), (line)-> $(line).tmplItem().id == line_data.id
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
    # set new line after the last visit
    $(_.last visits).after $.tmpl("tmpl/visit", { action: line_data.contract.action, date: line_data.start_date, lines: [line_data], user: line_data.contract.user })
    return true

  @allocate_linegroup = (line_data, linegroups)->
    line_start_date = moment(line_data.start_date).sod()
    line_end_date = moment(line_data.end_date).sod()
    for linegroup in linegroups
      linegroup_start_date = moment($(linegroup).tmplItem().data.start_date).sod()
      linegroup_end_date = moment($(linegroup).tmplItem().data.end_date).sod()
      if line_start_date.diff(linegroup_start_date, "days") < 0 or (line_start_date.diff(linegroup_start_date, "days") == 0 and line_end_date.diff(linegroup_end_date, "days") < 0)
        # set new linegroup before this one
        $(linegroup).closest(".indent").before $.tmpl("tmpl/linegroup", new GroupedLines([line_data]))
        return true
      else if (linegroup_start_date.diff(line_start_date, "days") == 0) and (linegroup_end_date.diff(line_end_date, "days") == 0)
        $(linegroup).find(".lines").append $.tmpl("tmpl/line", line_data)
        return true
    # set new linegroup after the last linegroup
    $(_.last linegroups).closest(".indent").after $.tmpl("tmpl/linegroup", new GroupedLines([line_data])) 
    return true
   
window.AddItem = AddItem