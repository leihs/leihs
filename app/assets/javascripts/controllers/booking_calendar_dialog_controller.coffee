class window.App.BookingCalendarDialogController extends Spine.Controller

  constructor: ->
    super
    do @setupModal
    do @setupDates
    do @setupQuantity
    do @fetchData
    do @delegateEvents

  delegateEvents: =>
    @submitButton.on "click", @submit
    @dialog.on "change", "input", => @errorsContainer.html ""
    @dialog.on "validation-alert", => do @validationAlerts

  done: =>
    @modal.destroyable()
    App.Modal.destroyAll true

  fail: (e)=>
    @modal.destroyable()
    @showError e.responseText

  fetchData: => #virtual
          
  fetchWorkdays: =>
    App.Workday.ajaxFetch().done (data)=> @workdays = (App.Workday.find datum.id for datum in data)

  fetchHolidays: =>
    App.Holiday.ajaxFetch().done (data)=> @holidays = (App.Holiday.find datum.id for datum in data)

  fetchGroups: =>
    App.Group.ajaxFetch().done (data)=> @groups = (App.Group.find datum.id for datum in data)

  fetchAvailability: => # virtual

  getAvailability: (inventoryPool)=> # virtual

  getEndDate: => moment(@endDateEl.val(), i18n.date.L)

  getStartDate: => moment(@startDateEl.val(), i18n.date.L)

  getQuantity: => parseInt(@quantityEl.val()) if @quantityEl.val().length

  getSelectedInventoryPool: => App.InventoryPool.find @inventoryPoolSelect.find("option:selected").data "id"

  initalizeDialog: =>
    @loading.detach()
    @controlElements.removeClass "hidden"
    @submitButton.prop "disabled", false
    do @setupBookingCalendar

  setupModal: =>
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

  setupBookingCalendar: => #virtual

  submit: =>
    if @valid()
      @modal.undestroyable()
      do @showOverlay
      do @showSubmitting
      do @store

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

  valid: => #virtual

  validationAlerts: =>
    if @valid()
      @errorsContainer.html ""
    else
      @showError @errors.join(", ")
