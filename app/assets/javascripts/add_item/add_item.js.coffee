###

Add Item 

This script provides functionalities to add items to orders and visits
 
http://leihs.zhdk.ch/backend/inventory_pools/1/models?end_date=2012-02-24&layout=modal%3D2012-02-22&start_date=2012-02-22&user_id=5397
###
   
jQuery ->
  AddItem.setup()

class AddItem
  
  @setup: ->
    @bind_open_dialog()
   
  @bind_open_dialog: ->
    $(".open_dialog.add_item").live "click", ->
      _this = $(this) 
      data = eval _this.data("ref_for_dialog")
      start_date = $("#add_start_date").datepicker("getDate")
      start_date = start_date.getFullYear()+"-"+(start_date.getMonth()+1)+"-"+start_date.getDate()
      end_date = $("#add_end_date").datepicker("getDate")
      end_date = end_date.getFullYear()+"-"+(end_date.getMonth()+1)+"-"+end_date.getDate()
      AddItem.load_model_data
        url: _this.attr("href")
        data:
          user_id: data.user.id
          start_date: start_date
          end_date: end_date
          image_thumb: 1
      
  @load_model_data: ()->
    ajax_options = arguments[0]
    $.extend ajax_options, data: format:"json"
    $.extend ajax_options, success: AddItem.setup_models
    $.ajax ajax_options
    
  @setup_models: (data)->
    $(".ui-dialog.add_item img.loading").remove()
    $(".ui-dialog.add_item .models.list").append $.tmpl "tmpl/line/add_item/model", data
    Dialog.rescale($(".add_item .dialog"))
    $(".ui-dialog.add_item .models.list").removeClass("invisible").addClass("visible")
   
window.AddItem = AddItem