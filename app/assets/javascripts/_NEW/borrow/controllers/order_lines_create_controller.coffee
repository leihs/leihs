class window.App.Borrow.OrderLinesCreateController extends window.App.Borrow.OrderLinesChangeController

  # @override
  getAvailability: (inventoryPool)=> @availabilities[inventoryPool.id]

  # @override
  setupQuantity: -> true

  # @override
  setupInventoryPool: ->
    inventoryPoolIds = App.Borrow.ModelsIndexIpSelectorController.activeInventoryPoolIds
    for id in inventoryPoolIds
      option = @inventoryPoolSelect.find "option[data-id='#{id}']"
      if option.length
        option.attr "selected", true
        break

  # @override
  setupDates: =>
    if sessionStorage.startDate?
      @startDateEl.val sessionStorage.startDate
    else
      @startDateEl.val moment().format("YYYY-MM-DD")
    if sessionStorage.endDate?
      @endDateEl.val sessionStorage.endDate
    else
      @endDateEl.val moment().add("days", 1).format("YYYY-MM-DD")

  # @override
  store: => 
    ajax = @createOrderLine parseInt(@quantityEl.val())
    ajax.done @done
    ajax.fail @fail
