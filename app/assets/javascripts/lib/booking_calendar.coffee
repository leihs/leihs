class BookingCalendar

  @sessionStorage = false
  @local = 
    dateFormat: i18n.date.L
    firstDay: i18n.days.first
    buttonText: 
      today: i18n.today
      month: i18n.month
      week: i18n.week
      day: i18n.day
    monthNames: i18n.months.full
    monthNamesShort: i18n.months.trunc
    dayNames: i18n.days.full
    dayNamesShort: i18n.days.trunc

  constructor: (options)->
    options ?= {}
    @fullcalendar = if options.calendarEl? then options.calendarEl else $("#fullcalendar")
    @el = if options.el? then options.el else @fullcalendar.closest "form"
    @el.find(".quantity").remove() if options.withoutQuantity
    @quantity_el = if options.quantityEl? then options.quantityEl else @el.find(".quantity input")
    @startDate_el = if options.startDateEl? then options.startDateEl else @el.find("#start_date")
    @endDate_el = if options.endDateEl? then options.endDateEl else @el.find("#end_date")
    @limitMaxQuantity = if options.limitMaxQuantity? then options.limitMaxQuantity else true
    @groupIds = options.groupIds
    @availability = options.availability
    @renderFunctionCallback = options.renderFunctionCallback
    @setup options
    do @setupFromSessionStorage if BookingCalendar.sessionStorage
    do @formatDates
    do @setupDates
    do @setupQuantity
    do @setupDateJumper
    do @setupFullcalendar
    do @setupCalendarNavigation
    do @setupFirstView
    do @setupDayCells

  setupFromSessionStorage: =>
    if sessionStorage.start_date and sessionStorage.end_date
      @startDate_el.val JSON.parse sessionStorage.start_date
      @endDate_el.val JSON.parse sessionStorage.end_date

  formatDates: =>
    _.each [@startDate_el, @endDate_el], (el)=> el.val moment(el.val()).startOf("day").format(df)
    _.each [@startDate_el, @endDate_el], (el)=> @validateDate el

  setupDates: =>
    _.each [@startDate_el, @endDate_el], (el)=> 
      el.bind "keyup", (e) =>
        if e.keyCode is 38 then @increaseDate(el) else if e.keyCode is 40 then @decreaseDate(el)
        clearTimeout el.data "keyup_timer" if el.data("keyup_timer")?
        el.data "keyup_timer", window.setTimeout =>
          if @validateDate el
            @goToDate moment(el.val(), df)
            do @render
          else 
            @resetDate el
        , 600
      el.bind "change", (e) => 
        if @validateDate el
          do @render
        else 
          @resetDate el

  increaseDate: (el)=>
    el.val(moment(el.val(), df).add("days", 1).format(df)).change()

  decreaseDate: (el)=>
    el.val(moment(el.val(), df).subtract("days", 1).format(df)).change()

  validateDate: (date_el)=>
    if date_el.val().length and moment(date_el.val(), df).format(df) is date_el.val() and moment(date_el.val(), df).year() < 9999
      @validateDateLogic date_el
      date_el.data "date", moment(date_el.val(), df).toDate()
      return true
    else
      return false

  resetDate: (date_el)=>
    date_el.val(moment(date_el.data("date")).format(df)).change()
    window.setTimeout (-> date_el.focus().select()), 150

  validateDateLogic: (date_el)=>
    dateToday = moment().startOf("day").toDate()
    startDate = moment(@startDate_el.val(),df)
    endDate = moment(@endDate_el.val(),df)
    if startDate < dateToday and @startDate_el.is(":not(:disabled)")
      @startDate_el.val(moment(dateToday).format(df)).change()
    if endDate < startDate
      if date_el is @endDate_el
        @startDate_el.val(moment(endDate).format(df)).change()
      else if date_el is @startDate_el
        @endDate_el.val(moment(startDate).format(df)).change()
      else
        @endDate_el.val(moment(startDate).format(df)).change()

  setupFullcalendar: =>
    @fullcalendar.html ""
    @fullcalendar.fullCalendar
      viewDisplay: @renderFunction
      header:
        left: "title",
        right: "today prev next"
      firstDay: BookingCalendar.local.firstDay
      buttonText: BookingCalendar.local.buttonText
      monthNames: BookingCalendar.local.monthNames
      monthNamesShort: BookingCalendar.local.monthNamesShort
      dayNames: BookingCalendar.local.dayNames
      dayNamesShort: BookingCalendar.local.dayNamesShort

  setupCalendarNavigation: =>
    @fullcalendar.find(".fc-button-next .fc-button-content").html "<span class='icon-chevron-right'></span>"
    @fullcalendar.find(".fc-button-prev .fc-button-content").html "<span class='icon-chevron-left'></span>"

  setMaxQuantity: (quantity)=> 
    @quantity_el.attr "max", quantity if @limitMaxQuantity

  setupQuantity: =>
    if @quantity_el.val().length
      @quantity_el.removeAttr("max") unless @limitMaxQuantity
      @quantity_el.click (e)=> e.currentTarget.select()
      @quantity_el.bind "keyup", (e)=>
        do @increaseQuantity if e.keyCode is 38
        do @decreaseQuantity if e.keyCode is 40
        do @resetQuantity unless @validateQuantity()
        $(e.currentTarget).change()
      @quantity_el.bind "change", (e)=> 
        if @validateQuantity()
          do @render
        else 
          do @resetQuantity
    else
      @quantity_el.prop "disabled", true

  increaseQuantity: => @quantity_el.val(parseInt(@quantity_el.val())+1).change()

  decreaseQuantity: => @quantity_el.val(parseInt(@quantity_el.val())-1).change()
  
  validateQuantity: =>
    return false if @quantity_el.val().match(/\D/)
    value = parseInt(@quantity_el.val())
    max = @quantity_el.attr("max")
    min = @quantity_el.attr("min")
    if value <= 0 or isNaN(value)
      return false
    else if max? and value > max or value < min
      return false
    else
      @quantity_el.data "last_value", @quantity_el.val()
      return true

  resetQuantity: =>
    if parseInt(@quantity_el.val()) > @quantity_el.attr("max")
      @quantity_el.val @quantity_el.attr("max")
    else if @quantity_el.data("last_value")?
      @quantity_el.val @quantity_el.data "last_value"
    @quantity_el.select()

  setupDateJumper: =>
    if @startDate_el.is(":disabled") then @el.find("#jump-to-start-date").hide() else @el.find("#jump-to-start-date").click =>  @goToDate moment(@startDate_el.val(), df)
    @el.find("#jump-to-end-date").click => @goToDate moment(@endDate_el.val(), df)

  goToDate: (date)=>
    date = moment() if date.diff(moment(), "days") < 0
    fullcalendar_date = moment @fullcalendar.fullCalendar("getDate")
    @fullcalendar.fullCalendar "gotoDate", date.toDate() if date.month() isnt fullcalendar_date.month() or date.year() isnt fullcalendar_date.year()

  setupFirstView: =>
    if @startDate_el.is ":disabled"
      @goToDate moment(@endDate_el.val(), df)
    else
      @goToDate moment(@startDate_el.val(), df)

  render: => @fullcalendar.fullCalendar "render"

  renderFunction: (view)=>
    holidaysInView = @holidaysBetween @getHolidays(), view.visStart, view.visEnd
    do @resetCalendarView
    do @setTails
    do @toggleGoBack
    do @setOtherMonth
    @firstRenderDone = true
    _.each @fullcalendar.find(".fc-widget-content"), (dayElement)=> 
      available = true
      availableInTotal = true
      availableQuantity = undefined
      totalQuantity = undefined
      dayElement = $(dayElement)
      date = @getDateByElement dayElement
      holidays = @holidaysBetween(holidaysInView, date, date)
      @resetDay dayElement
      dayElement.attr "data-date", moment(date).format("YYYY-MM-DD")
      # history date or future/today
      if date < moment().startOf("day").toDate()
        dayElement.addClass "history"
      else # today or future day
        @setHolidays dayElement, holidays if holidays.length
        @setDayElement date, dayElement, holidays
        @setClosedDay date, dayElement
    do @renderFunctionCallback if @renderFunctionCallback?

  setClosedDay: (date, dayElement)=>
    if @isClosedDay date
      dayElement.addClass "closed"

  validation: => @el.trigger "validation-alert"

  isClosedDay: (date)=>
    @getInventoryPool().isClosedOn(moment(date))

  setOtherMonth: =>
    for dayElement in @fullcalendar.find(".fc-other-month")
      date = @getDateByElement dayElement
      dayElement = $(dayElement)
      dayElement.find(".fc-day-content").append("<span class='other_month'></span>") if dayElement.find(".fc-day-content .other_month").length == 0
      dayElement.find(".fc-day-content .other_month").text BookingCalendar.local.monthNamesShort[date.getMonth()]

  setHolidays: (dayElement, holidays)=>
    dayElement.addClass "holiday"
    dayElement.find(".fc-day-content").append("<span class='holidays'></span>") if dayElement.find(".fc-day-content .holidays").length == 0
    dayElement.find(".fc-day-content .holidays").append("<span class='entry' title='#{holiday.name}'>#{holiday.name}</span>") for holiday in holidays 

  holidaysBetween: (holidays, startDate, endDate)=>
    _.filter holidays, (holiday)-> 
      holidayStartDate = moment(holiday.start_date).toDate()
      holidayEndDate = moment(holiday.end_date).toDate()
      holidayStartDate <= startDate and endDate <= holidayEndDate or
      startDate <= holidayStartDate <= endDate or 
      startDate <= holidayEndDate <= endDate

  toggleGoBack: =>
    if @fullcalendar.fullCalendar("getDate") <= new Date()
      @fullcalendar.find(".fc-button-prev").addClass "fc-state-disabled"
    else
      @fullcalendar.find(".fc-button-prev").removeClass "fc-state-disabled"

  setTails: =>
    set = (dayElement, el_class, tailId)=>
      dayElement.addClass el_class
      @el.find(tailId).remove()
      dayElement.children("div").append "<div id='#{tailId}' class='calendar-tail'></div>"
      dayElement.find("##{tailId}").show()

    visibleStartDate_el = @getElementByDate moment(@startDate_el.val(), df).toDate()
    visibleEndDate_el = @getElementByDate moment(@endDate_el.val(), df).toDate()
    set $(visibleStartDate_el), "start-date", "calendar-tail-left" if visibleStartDate_el?
    set $(visibleEndDate_el), "end-date", "calendar-tail-right" if visibleEndDate_el?

  resetDay: (dayElement)=>
    dayElement.removeClass "selected"
    dayElement.removeClass "history"
    dayElement.removeClass "holiday"
    dayElement.find(".fc-day-content > div").text ""
    dayElement.find(".holidays").text ""
    dayElement.find(".total_quantity").text ""

  resetCalendarView: =>
    @fullcalendar.find(".calendar-tail").remove()
    @fullcalendar.find(".other_month").text ""
    @fullcalendar.find(".closed").removeClass "closed"
    @fullcalendar.find(".start-date").removeClass "start-date"
    @fullcalendar.find(".end-date").removeClass "end-date"

  setSelected: (dayElement, date)=>
    startDate = moment(@startDate_el.val(), df).startOf("day").toDate()
    endDate = moment(@endDate_el.val(), df).startOf("day").toDate()
    if date >= startDate && date <= endDate
      dayElement.addClass "selected"
    else
      dayElement.removeClass "selected"
    do @validation

  setAvailability: (dayElement, available)=>
    if available then dayElement.removeClass("unavailable").addClass("available") else dayElement.removeClass("available").addClass("unavailable")

  getDateByElement: (el)=>
    return @fullcalendar.fullCalendar("getView").cellDate
      col: $(el).index()
      row: $(el).parent().index()

  getElementByDate: (date)=>
    view = @fullcalendar.fullCalendar("getView")
    if view.visStart <= date <= view.visEnd
      cell = view.dateCell(date)
      row = @fullcalendar.find(".fc-view > table > tbody > tr")[cell.row]
      return $(row).find("td")[cell.col]
    else
      return false

  setupDayCells: =>
    resetSelection = =>
      for target in @fullcalendar.find(".selected_for_target_selection")
        target = $(target)
        target.removeClass "selected_for_target_selection"
        if target.data("tooltipster") and not target.data("tooltipster").hasClass("tooltipster-dying")
          target.tooltipster("enable").tooltipster("destroy")
    $(window).bind "click", (e)=> 
      unless $(e.target).closest(".target-selection").length
        do resetSelection
    @fullcalendar.find(".fc-widget-content").bind "click", (e)=>
      date = @getDateByElement e.currentTarget
      target = $(e.currentTarget)
      if moment(date).startOf("day").diff(moment().startOf("day"), "days") < 0
        do resetSelection
      else if @startDate_el.is ":disabled"
        @endDate_el.val(moment(date).format(df)).change()
      else
        do resetSelection
        target.addClass "selected_for_target_selection"
        new App.Tooltip
          el: target
          content: App.Render "views/booking_calendar/target-selection"
          interactive: true
          delay: 0
          trigger: false
          callback: (origin, tooltip)=>
            $(tooltip).one "click", "button", (e)=>
              do resetSelection
              if $(e.currentTarget).is "#set-start-date"
                @startDate_el.val(moment(date).format(df)).change()
              else if $(e.currentTarget).is "#set-end-date"
                @endDate_el.val(moment(date).format(df)).change()
              do @validation
        target.tooltipster("enable")
        target.tooltipster("show")
        target.tooltipster("disable")
      e.stopPropagation()
      return false

  getAvailability: => #virtual
  getGroupIds: => #virtual
  getInventoryPool: => #virtual
  setDayElement: (date, dayElement, holidaysInView)=> #virtual
  setQuantityText: (dayElement, availableQuantity, totalQuantity)=> #virtual
  getHolidays: => #virtual
  setupPartitionSelector: => #virtual
  setup: => #virtual

window.App.BookingCalendar = BookingCalendar
df = BookingCalendar.local.dateFormat