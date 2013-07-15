class window.App.Borrow.OrderLinesCreateController extends Spine.Controller

  constructor: ->
    super
    return false unless App.Model.exists @modelId
    do App.Tooltip.destroyAll
    @availabilities = {}
    do @setupModal
    do @setupDates
    do @fetchData
    do @delegateEvents

  delegateEvents: =>
    @addToOrderButton.on "click", @submit
    @dialog.on "change", "*", => @errorsContainer.html ""
    @modal.el.on "hide", => do App.Tooltip.destroyAll

  setupModal: =>
    @dialog = $ App.Render "borrow/views/order/add/calendar_dialog", {model: App.Model.find(@modelId)}
    @loading = @dialog.find "img.loading"
    @addToOrderButton = @dialog.find "#add-to-order"
    @controlElements = @dialog.find "#booking-calendar-controls"
    @inventoryPoolSelect = @dialog.find "#order-inventory-pool"
    @quantity = @dialog.find "#order-quantity"
    @errorsContainer = @dialog.find "#add-to-order-errors"
    @modal = new App.Modal @dialog

  setupDates: =>
    @startDate = @dialog.find("#order-start-date")
    @endDate = @dialog.find("#order-end-date")
    if sessionStorage.startDate?
      @startDate.val sessionStorage.startDate
    else
      @startDate.val moment().format("YYYY-MM-DD")
    if sessionStorage.endDate?
      @endDate.val sessionStorage.endDate
    else
      @endDate.val moment().add("days", 1).format("YYYY-MM-DD")

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

  initalizeDialog: =>
    if @workdays and @holidays and @groups and _.size(@availabilities) == App.InventoryPool.all().length
      @loading.detach()
      @controlElements.removeClass "hidden"
      @addToOrderButton.attr "disabled", false
      do @renderInventoryPools
      do @setupBookingCalendar

  renderInventoryPools: =>
    @inventoryPoolSelect.html ""
    for inventoryPool in _.sortBy(App.InventoryPool.all(), (ip)-> ip.name)
      av = @availabilities[inventoryPool.id]
      if av.total_borrowable > 0
        option = $ App.Render "borrow/views/order/add/inventory_pool_option", inventoryPool, {availability: av}
        option.data "availability", av
        option.data "holidays", inventoryPool.holidays().all()
        option.data "closed_days", inventoryPool.workday().closedDays()
        @inventoryPoolSelect.append option

  setupBookingCalendar: =>
    new App.BorrowBookingCalendar
      calendarEl: @dialog.find "#booking-calendar"
      startDateEl: @startDate
      endDateEl: @endDate
      quantityEl: @dialog.find "#order-quantity"
      ipSelectorEl: @dialog.find "#order-inventory-pool"
      quantityMode: "numbers"
      groupIds: _.map App.Group.all(), (g)-> g.id

  submit: =>
    @modal.undestroyable = true
    do @showOverlay
    do @showSubmitting
    @errorsContainer.html ""
    do App.Tooltip.destroyAll
    order_line = new App.OrderLine
      model_id: @modelId
      quantity: parseInt @quantity.val()
      start_date: moment(@startDate.val(), i18n.date.L).format("YYYY-MM-DD")
      end_date: moment(@endDate.val(), i18n.date.L).format("YYYY-MM-DD")
      inventory_pool_id: @inventoryPoolSelect.find("option:selected").data "id"
    ajax = App.OrderLine.ajaxChange(order_line, "create", {})
    ajax.done(@done)
    ajax.fail (e)=>
      @modal.undestroyable = false
      @showError e.responseText

  showOverlay: => 
    @overlay ?= $ App.Render "views/booking_calendar/overlay"
    @dialog.append @overlay

  showSubmitting: =>
    @addToOrderButton.data "html", @addToOrderButton.html()
    @addToOrderButton.html App.Render("views/loading", {size: "micro"})

  showError: (text)=>
    @overlay.detach()
    @addToOrderButton.html @addToOrderButton.data("html")
    @errorsContainer.html App.Render "views/booking_calendar/errors", {text: text}

  done: (data)=>
    App.Order.trigger "refresh", App.Order.current
    @modal.undestroyable = false
    App.Modal.destroyAll true