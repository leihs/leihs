class window.App.Borrow.OrderLinesCreateController extends window.App.Borrow.OrderLinesChangeController

  # @override
  getAvailability: (inventoryPool)=> @availabilities[inventoryPool.id]

  # @overried
  setupQuantity: -> true

  # @override
  setupDates: =>
    if sessionStorage.startDate?
      debugger
      @startDateEl.val sessionStorage.startDate
    else
      @startDateEl.val moment().format("YYYY-MM-DD")
    if sessionStorage.endDate?
      @endDateEl.val sessionStorage.endDate
    else
      @endDateEl.val moment().add("days", 1).format("YYYY-MM-DD")

  # @override
  synchronize: => 
    ajax = @createOrderLine parseInt(@quantityEl.val())
    ajax.done @done
    ajax.fail @fail
