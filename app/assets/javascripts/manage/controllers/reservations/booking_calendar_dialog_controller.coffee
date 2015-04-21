class window.App.ManageBookingCalendarDialogController extends App.BookingCalendarDialogController
    
  # overwrite
  setupModal: =>
    @dialog = $ App.Render "manage/views/booking_calendar/calendar_dialog", {user: @user}, {startDateDisabled: @startDateDisabled, quantityDisabled: @quantityDisabled}
    @listOfLines = @dialog.find("#booking-calendar-lines .list-of-lines")
    @partitionsEl = @dialog.find("#booking-calendar-partitions")
    super    

  # overwrite
  setupDates: =>
    @startDateEl.val (_.min @lines, (l)-> Date.parse l.start_date).start_date
    @endDateEl.val (_.max @lines, (l)-> Date.parse l.end_date).end_date

  # overwrite
  fetchData: =>
    @fetchWorkdays().done => do @initalizeDialog
    @fetchHolidays().done => do @initalizeDialog
    @fetchPartitions().done => @fetchGroups().done => do @initalizeDialog
    if _.any(@models, (m)-> not m.availability?()?)
      @fetchAvailability().done => do @initalizeDialog
    else
      @availabilities = true

  fetchAvailability: =>
    App.Availability.ajaxFetch
      data: $.param
        model_ids: _.map @models, (m)-> m.id
        user_id: @user.id
    .done => @availabilities = true

  fetchPartitions: =>
    App.Partition.ajaxFetch
      data: $.param
        model_ids: _.map @models, (m)-> m.id
    .done (data)=> 
      @partitions = (App.Partition.find "#{datum.model_id}#{datum.inventory_pool_id}#{datum.group_id}" for datum in data)

  fetchGroups: =>
    App.Group.ajaxFetch
      data: $.param
        group_ids: _.compact _.uniq(_.map @partitions, (p)-> p.group_id)
    .done (data)=> 
      @groups = (App.Group.find datum.id for datum in data)
      do @setupPartitions

  # overwrite
  initalizeDialog: =>
    return false unless @workdays and @holidays and @availabilities and @partitions and @groups
    super

  setupPartitions: =>
    data = {user: [], userGroups: [], otherGroups: []}
    data.user = @user.groupIds
    for partition in @partitions
      if partition.group_id?
        if _.include @user.groupIds, partition.group_id
          data.userGroups.push partition.group()
        else
          data.otherGroups.push partition.group()
    @partitionsEl.html App.Render "manage/views/booking_calendar/partitions", data

  setupBookingCalendar: =>
    new App.ManageBookingCalendar
      calendarEl: @dialog.find "#booking-calendar"
      startDateEl: @startDateEl
      startDateDisabled: @startDateDisabled
      endDateEl: @endDateEl
      quantityEl: @dialog.find "#booking-calendar-quantity"
      groupIds: @user.groupIds
      partitions: @partitions
      lines: @lines
      models: @models
      renderFunctionCallback: @calendarRendered

  calendarRendered: =>
    options =
      groupIds: @user.groupIds
      start_date: moment(@startDateEl.val(), i18n.date.L)
      end_date: moment(@endDateEl.val(), i18n.date.L)
      quantity: @getQuantity()
    @listOfLines.html App.Render "manage/views/booking_calendar/line", @mergedLines, options

  # overwrite
  getSelectedInventoryPool: => App.InventoryPool.current

  # overwrite
  validationAlerts: =>
    # NOTE this are just warnings (not preventing as error) # TODO dry with super valid()
    ip = @getSelectedInventoryPool()
    errors = []
    if not ip.isVisitPossible @getStartDate()
      errors.push _jed("Booking is no longer possible on this start date")
    if not ip.isVisitPossible @getEndDate()
      errors.push _jed("Booking is no longer possible on this end date")
    if ip.isClosedOn @getStartDate()
      errors.push _jed("Inventory pool is closed on start date")
    if ip.isClosedOn @getEndDate()
      errors.push _jed("Inventory pool is closed on end date")

    if errors.length
      @showError errors.join(", ")
    else
      @errorsContainer.html ""

  valid: => true

  store: => # virtual