###

Add Item 

This script provides functionalities to add items to orders and visits
 
###
   
jQuery ->
  AddItem.setup()

class AddItem
  
  @setup: ->
    @setup_date_change()
  
  @setup_date_change: ()->
    $("#add_item .date").on "change", (event)->
      $(this).data "date", moment($(this).val(),i18n.date.L) 
      LineGroup.highlightSelected $("#add_item #add_start_date").data("date"), $("#add_item #add_end_date").data("date")
      
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
    
  @updateTimerange: (start_date, end_date)->
    if($("#add_item #add_start_date").val() != moment(start_date).format(i18n.date.L))
      $("#add_item #add_start_date").val(moment(start_date).format(i18n.date.L)).change()
    
    if($("#add_item #add_end_date").val() != moment(end_date).format(i18n.date.L))
      $("#add_item #add_end_date").val(moment(end_date).format(i18n.date.L)).change();
      $("#add_item #add_end_date").datepicker('setDate', moment(end_date).format(i18n.date.L));
   
window.AddItem = AddItem