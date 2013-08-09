class window.App.Borrow.TemplateLineChangeController extends window.App.Borrow.BookingCalendarDialog

  # overwrite
  getAvailability: (inventoryPool)=> @availabilities[inventoryPool.id]

  # overwrite
  store: ->
    App.TemplateLine.update @templateLine.id,
      quantity: @getQuantity()
      inventory_pool_id: @getSelectedInventoryPool().id
      available: true
      start_date: @getStartDate().format "YYYY-MM-DD"
      end_date: @getEndDate().format "YYYY-MM-DD"
    do @done