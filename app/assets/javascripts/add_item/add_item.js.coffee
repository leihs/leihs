###

Add Item 

This script provides functionalities to add items to orders and visits
 
###
   
jQuery ->
  AddItem.setup()

class AddItem
  
  @setup: ->
    $("#add_item_button").live "click", (event)->
      quick_add = $(this).closest("#add_item").find("#quick_add")
      if quick_add.length > 0 and quick_add.val() != ""
        stop
        console.log "ADD ITEM WITH VALUE:"+quick_add.val()
      else
        AddItem.open_dialog $(this)
        
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
   
window.AddItem = AddItem