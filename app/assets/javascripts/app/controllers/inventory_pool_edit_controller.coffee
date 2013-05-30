class InventoryPoolEditController
  
  constructor: (options)->
    @el = $(options.el)
    do @delegateEvents

  delegateEvents: ->
    @el.on "click", ".delete-holiday", @deleteHoliday
    @el.on "click", ".add-holiday", @addHoliday

  deleteHoliday: (e)=>
    e.preventDefault()
    entry = $(e.currentTarget).closest(".field-inline-entry")
    i = entry.data "index"
    if entry.find("input[name='inventory_pool[holidays_attributes][#{i}][_destroy]']").length
      entry.find("span").removeClass "tobedeleted"
      entry.find("input[name='inventory_pool[holidays_attributes][#{i}][_destroy]']").remove()
    else
      entry.find("span:not(.clickable)").addClass "tobedeleted"
      entry.prepend("<input type='hidden' name='inventory_pool[holidays_attributes][#{i}][_destroy]' value='1' />")

  addHoliday: (e)=>
    e.preventDefault()
    container = $(e.currentTarget).closest(".field")
    start_date = moment(container.find("#start_date").val(), i18n.date.L).format("YYYY-MM-DD")
    end_date = moment(container.find("#end_date").val(), i18n.date.L).format("YYYY-MM-DD")
    name = container.find("#name").val()
    last_holiday_index = _.last(_.sortBy(_.map(@el.find(".field-inline-entry"), (e)->$(e).data("index")), (e)->Number(e)))
    i = if last_holiday_index? then last_holiday_index + 1 else 0
    if start_date? and end_date? and name.length
      container.after $.tmpl "app/views/inventory_pools/edit/holiday_entry", {name: name, start_date: start_date, end_date: end_date, i: i}

window.App.InventoryPoolEditController = InventoryPoolEditController
