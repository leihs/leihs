class window.App.BorrowBookingCalendarDialogController extends App.BookingCalendarDialogController

  constructor: (options)->
    @availabilities = {}
    super

  # overwrite
  setupModal: =>
    @dialog = $ App.Render "borrow/views/booking_calendar/calendar_dialog", {model: App.Model.find(@modelId), titel: @titel, buttonText: @buttonText}
    super

  # overwrite
  fetchData: =>
    App.InventoryPool.ajaxFetch().done => 
      @fetchWorkdays().done => do @initalizeDialog
      @fetchHolidays().done => do @initalizeDialog
      @fetchGroups().done => do @initalizeDialog
      for ip in App.InventoryPool.all()
        @fetchAvailability(ip.id).done => do @initalizeDialog

  # overwrite
  fetchAvailability: (inventoryPoolId)=>
    App.Availability.ajaxFetch
      data: $.param 
        model_id: @modelId, inventory_pool_id: inventoryPoolId
    .done (availability)=> @availabilities[availability.inventory_pool_id] = App.Availability.find availability.id

  # overwrite
  initalizeDialog: =>
    return false unless @workdays and @holidays and @groups and _.size(@availabilities) == App.InventoryPool.all().length
    do @renderInventoryPools
    do @selectFirstInventoryPool
    super

  selectFirstInventoryPool: => # virtual

  renderInventoryPools: =>
    @inventoryPoolSelect.html ""
    for inventoryPool in _.sortBy(App.InventoryPool.all(), (ip)-> ip.name)
      av = @getAvailability inventoryPool
      if av.total_borrowable > 0
        option = $ App.Render "borrow/views/booking_calendar/inventory_pool_option", inventoryPool, {availability: av}
        option.data "availability", av
        option.data "holidays", inventoryPool.holidays().all()
        option.data "closed_days", inventoryPool.workday().closedDays()
        @inventoryPoolSelect.append option

  # overwrite
  setupBookingCalendar: =>
    new App.BorrowBookingCalendar
      calendarEl: @dialog.find "#booking-calendar"
      startDateEl: @startDateEl
      endDateEl: @endDateEl
      quantityEl: @dialog.find "#booking-calendar-quantity"
      ipSelectorEl: @dialog.find "#booking-calendar-inventory-pool"
      quantityMode: "numbers"
      groupIds: _.map App.Group.all(), (g)-> g.id

  # overwrite
  valid: =>
    ip = @getSelectedInventoryPool()
    av = @availabilities[ip.id]
    av = av.withoutLines(@lines) if @withoutLines
    @errors = []
    if av.maxAvailableForGroups(@getStartDate(), @getEndDate(), _.map(@groups,(g)->g.id)) < @getQuantity()
      @errors.push _jed("Item is not available in that time range")
    if ip.isClosedOn @getStartDate() or not ip.isVisitPossible @getStartDate()
      @errors.push _jed("Inventory pool is closed on start date")
    if ip.isClosedOn @getEndDate() or not ip.isVisitPossible @getEndDate()
      @errors.push _jed("Inventory pool is closed on end date")
    return ! @errors.length

  # overwrite
  submit: =>
    if @valid()
      @errorsContainer.html ""
    else
      @showError @errors.join(", ")
    super
