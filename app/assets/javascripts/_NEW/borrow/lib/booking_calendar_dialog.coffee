class window.App.Borrow.BookingCalendarDialog extends Spine.Controller

  constructor: ->
    super
    return false unless App.Model.exists @modelId
    do App.Tooltip.destroyAll
    @availabilities = {}
    do @setupModal
    do @setupDates
    do @setupQuantity
    do @fetchData
    do @delegateEvents

  delegateEvents: =>
    @submitButton.on "click", @submit
    @dialog.on "change", "*", => @errorsContainer.html ""
    @modal.el.on "hide", => do App.Tooltip.destroyAll

  done: (data)=>
    @modal.undestroyable = false
    App.Modal.destroyAll true

  fail: (e)=>
    @modal.undestroyable = false
    @showError e.responseText

  fetchData: =>
    App.InventoryPool.ajaxFetch().done => 
      @fetchWorkdays().done => do @initalizeDialog
      @fetchHolidays().done => do @initalizeDialog
      @fetchGroups().done => do @initalizeDialog
      for ip in App.InventoryPool.all()
        @fetchAvailability(ip.id).done => do @initalizeDialog
          
  fetchWorkdays: =>
    App.Workday.ajaxFetch().done => @workdays = true

  fetchHolidays: =>
    App.Holiday.ajaxFetch().done => @holidays = true

  fetchGroups: =>
    App.Group.ajaxFetch().done => @groups = true

  fetchAvailability: (inventoryPoolId)=>
    App.Availability.ajaxFetch
      data: $.param 
        model_id: @modelId, inventory_pool_id: inventoryPoolId
    .done (availability)=> 
      @availabilities[availability.inventory_pool_id] = new App.Availability availability

  getAvailability: (inventoryPool)=> # virtual

  getEndDate: => moment(@endDateEl.val(), i18n.date.L)

  getStartDate: => moment(@startDateEl.val(), i18n.date.L)

  getQuantity: => parseInt(@quantityEl.val())

  getSelectedInventoryPool: => App.InventoryPool.find @inventoryPoolSelect.find("option:selected").data "id"

  initalizeDialog: =>
    if @workdays and @holidays and @groups and _.size(@availabilities) == App.InventoryPool.all().length
      @loading.detach()
      @controlElements.removeClass "hidden"
      @submitButton.attr "disabled", false
      do @renderInventoryPools
      do @setupBookingCalendar

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

  setupModal: =>
    @dialog = $ App.Render "borrow/views/booking_calendar/calendar_dialog", {model: App.Model.find(@modelId), titel: @titel, buttonText: @buttonText}
    @loading = @dialog.find "img.loading"
    @submitButton = @dialog.find "#submit-booking-calendar"
    @controlElements = @dialog.find "#booking-calendar-controls"
    @inventoryPoolSelect = @dialog.find "#booking-calendar-inventory-pool"
    @quantityEl = @dialog.find "#booking-calendar-quantity"
    @errorsContainer = @dialog.find "#booking-calendar-errors"
    @startDateEl = @dialog.find("#booking-calendar-start-date")
    @endDateEl = @dialog.find("#booking-calendar-end-date")
    @modal = new App.Modal @dialog

  setupDates: =>
    @startDateEl.val @startDate
    @endDateEl.val @endDate

  setupQuantity: => @quantityEl.val @quantity

  setupBookingCalendar: =>
    new App.BorrowBookingCalendar
      calendarEl: @dialog.find "#booking-calendar"
      startDateEl: @startDateEl
      endDateEl: @endDateEl
      quantityEl: @dialog.find "#booking-calendar-quantity"
      ipSelectorEl: @dialog.find "#booking-calendar-inventory-pool"
      quantityMode: "numbers"
      groupIds: _.map App.Group.all(), (g)-> g.id

  submit: =>
    if @valid()
      @modal.undestroyable = true
      do @showOverlay
      do @showSubmitting
      @errorsContainer.html ""
      do App.Tooltip.destroyAll
      do @store
    else 
      @showError @errors.join(", ")

  store: => # virtual

  showOverlay: => 
    @overlay ?= $ App.Render "views/booking_calendar/overlay"
    @dialog.append @overlay

  showSubmitting: =>
    @submitButton.data "html", @submitButton.html()
    @submitButton.html App.Render("views/loading", {size: "micro"})

  showError: (text)=>
    @overlay.detach() if @overlay?
    @submitButton.html @submitButton.data("html")
    @errorsContainer.html App.Render "views/booking_calendar/errors", {text: text}

  valid: =>
    ip = @getSelectedInventoryPool()
    av = @availabilities[ip.id]
    @errors = []
    if av.maxAvailableForGroups(@getStartDate(), @getEndDate(), _.map(@groups,(g)->g.id)) < @getQuantity()
      @errors.push _jed("Item is not available in that time range")
    if ip.isClosedOn @getStartDate()
      @errors.push _jed("Inventory pool is closed on start date")
    if ip.isClosedOn @getEndDate()
      @errors.push _jed("Inventory pool is closed on end date")
    return ! @errors.length