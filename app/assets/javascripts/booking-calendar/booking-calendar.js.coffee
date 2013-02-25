###

 Booking-Calendar

 This script setups the jquery FullCalendar plugin and adds
 additional features for booking/renting processes

 @name Booking-Calendar
 @dependencies: jQuery, moment.js, fullcalendar, i18n, underscore, qtip, jQuery.tmpl

###

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
    @fullcalendar = $("#fullcalendar")
    @el = if options.el? then options.el else $("#fullcalendar").closest "form"
    @lines = @el.find(".list .line")
    @el.find(".quantity").remove() if options.withoutQuantity
    @quantity_el = @el.find(".quantity input")
    @quantity_increase_el = @el.find(".quantity .increase")
    @quantity_decrease_el = @el.find(".quantity .decrease")
    @startDate_el = @el.find("#start_date")
    @startDate_el.attr "disabled", true if options.startDateDisabled
    @endDate_el = @el.find("#end_date")
    @ipSelector_el = @el.find("select#inventory_pool_id")
    @partitionSelector_el = @el.find "select#partition"
    @availabilityMode = if options.availabilityMode is "eachDay" or options.availabilityMode is "openDays" then options.availabilityMode else "eachDays"
    @computeAvailability = if options.computeAvailability? then options.computeAvailability else true
    @quantityMode = if options.quantityMode? then options.quantityMode else if @lines.length == 1 and $(@lines[0]).tmplItem().data.type != "option_line" then "numbers" else "boolean"
    @limitMaxQuantity = if options.limitMaxQuantity? then options.limitMaxQuantity else true
    do @setupFromSessionStorage if BookingCalendar.sessionStorage
    do @formatDates
    do @setupDates
    do @setupQuantity
    do @setupDateJumper
    do @setupInventoryPoolSelector
    do @setupPartitionSelector
    do @setupFullcalendar
    do @setupFirstView
    do @setupDayCells
    do @refreshCulprit

  setupFromSessionStorage: =>
    if sessionStorage.start_date and sessionStorage.end_date
      @startDate_el.val JSON.parse sessionStorage.start_date
      @endDate_el.val JSON.parse sessionStorage.end_date

  formatDates: =>
    _.each [@startDate_el, @endDate_el], (el)=> el.val moment(el.val()).sod().format(df)
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
            do @refreshCulprit
          else 
            @resetDate el
        , 600
      el.bind "change", (e) => 
        if @validateDate el
          do @render
          do @refreshCulprit
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
    dateToday = moment().sod().toDate()
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

  setMaxQuantity: (quantity)=> @quantity_el.attr "max", quantity if @limitMaxQuantity

  setupQuantity: =>
    @quantity_el.removeAttr("max") unless @limitMaxQuantity
    @quantity_el.click (e)=> e.currentTarget.select()
    @quantity_el.bind "keyup", (e)=>
      do @increaseQuantity if e.keyCode is 38
      do @decreaseQuantity if e.keyCode is 40
      do @resetQuantity unless @validateQuantity()
      window.setTimeout (-> $(e.currentTarget).change() ), 150
    @quantity_el.bind "change", (e)=> 
      if @validateQuantity()
        do @render
        do @refreshCulprit
      else 
        do @resetQuantity
    @quantity_increase_el.bind "click", => do @increaseQuantity
    @quantity_decrease_el.bind "click", => do @decreaseQuantity

  increaseQuantity: => @quantity_el.val(parseInt(@quantity_el.val())+1).change()

  decreaseQuantity: => @quantity_el.val(parseInt(@quantity_el.val())-1).change()
  
  validateQuantity: =>
    value = parseInt(@quantity_el.val())
    max = @quantity_el.attr("max")
    min = @quantity_el.attr("min")
    if value == 0 or isNaN(value)
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
    if @startDate_el.is(":disabled") then @el.find(".fc-goto-start").hide() else @el.find(".fc-goto-start").click => @goToDate moment(@startDate_el.val(), df)
    @el.find(".fc-goto-end").click => @goToDate moment(@endDate_el.val(), df)

  goToDate: (date)=>
    date = moment() if date.diff(moment(), "days") < 0
    fullcalendar_date = moment @fullcalendar.fullCalendar("getDate")
    @fullcalendar.fullCalendar "gotoDate", date.toDate() if date.month() isnt fullcalendar_date.month() or date.year() isnt fullcalendar_date.year()

  setupInventoryPoolSelector: =>
    _.each @ipSelector_el.find("option"), (option)->
      option = $(option)
      option.html "#{option.data("name")} #{option.data("address")} (max. #{option.data("total_borrowable")})"
    @ipSelector_el.find("option:first").select()
    @ipSelector_el.bind "change", =>
      @setMaxQuantity @ipSelector_el.find("option:selected").data("total_borrowable")
      do @render
      do @refreshCulprit
    @ipSelector_el.change()

  setupPartitionSelector: =>
    return false if not @partitionSelector_el? or @partitionSelector_el.find("option").length == 0
    @partitionSelector_el.find("option:first").select()
    @partitionSelector_el.bind "change", (e)=>
      @partitionSelector_el.closest(".select").find(".name").text @partitionSelector_el.find("option:selected").text()
      if @selectedPartitions()? then @fullcalendar.removeClass("total_quantity_only") else @fullcalendar.addClass("total_quantity_only")
      do @render
      do @refreshCulprit

  setupFirstView: =>
    if @startDate_el.is ":disabled"
      @goToDate moment(@endDate_el.val(), df)
    else
      @goToDate moment(@startDate_el.val(), df)

  render: => @fullcalendar.fullCalendar "render"

  renderFunction: (view)=>
    holidaysInView = @getHolidays view.visStart, view.visEnd, @ipSelector_el.find("option:selected").data("holidays")
    do @resetCalendarView
    do @setTails
    do @toggleGoBack
    do @setOtherMonth
    do @closedDayValidation

    _.each @fullcalendar.find(".fc-widget-content"), (day_el)=> 
      available = true
      availableInTotal = true
      availableQuantity = undefined
      totalQuantity = undefined
      day_el = $(day_el)
      date = @getDateByElement day_el
      @resetDay day_el
      day_el.attr "data-date", moment(date).format("YYYY-MM-DD")
      # history date or future/today
      if date < moment().sod().toDate()
        day_el.addClass "history"
      else # today or future day
        if @computeAvailability
          _.each @lines, (line)=>
            line = $(line).tmplItem().data
            if line.type != "option_line"
              av = new App.Availability(line.availability_for_inventory_pool, line)
              requiredQuantity = if @quantityMode is "boolean" or isNaN(@quantity_el.val()) then line.quantity else parseInt @quantity_el.val()
              totalQuantity = av.maxAvailableInTotal(date, date)
              availableQuantity = av.maxAvailableForGroups date, date, @selectedPartitions()
              available = availableQuantity >= requiredQuantity and available
              availableInTotal = totalQuantity >= requiredQuantity and availableInTotal

        if @lines.length is 1
          @setQuantityText day_el, availableQuantity, totalQuantity
        else
          @setQuantityText day_el, (if available then 1 else 0), (if availableInTotal then 1 else 0)

        @setAvailability day_el, available
        @setSelected day_el, date
        if holidaysInView.length > 0
          holidaysOnThatDay = @getHolidays(date, date, holidaysInView)
          @setHolidays day_el, holidaysOnThatDay if holidaysOnThatDay.length > 0

  closedDayValidation: =>
    for date_el in [@startDate_el, @endDate_el]
      date = moment(date_el.val(),df).toDate()
      el = @getElementByDate date
      console.log date
      if el # is in view
        holidays = @getHolidays(date,date,@ipSelector_el.find("option:selected").data("holidays"))
        @addClosedDayAlert el if @isClosedDay(date) or holidays.length > 0

  isClosedDay: (date)=> @ipSelector_el.find("option:selected").data("closed_days").indexOf(date.getDay()) isnt -1

  addClosedDayAlert: (el)=>
    el = $(el)
    el.addClass("closed").qtip
      content:
        text: _jed("This inventory pool is closed on that day.")
        title:
          text: _jed("Consider Opening Hours")
      position:
        my: "bottom center"
        at: "top center"
        viewport: $(window)
      show: 
        event: false
        ready: true
        delay: 0
        solo: false
        effect: (offset)->
          $(this).show()
          _this = $(this)
          window.setTimeout ->
            $(_this).qtip("hide")
          , 3000
      style: 
        classes: "closed-day-alert"
      hide: false

  setOtherMonth: =>
    for day_el in @fullcalendar.find(".fc-other-month")
      date = @getDateByElement day_el
      day_el = $(day_el)
      day_el.find(".fc-day-content").append("<span class='other_month'></span>") if day_el.find(".fc-day-content .other_month").length == 0
      day_el.find(".fc-day-content .other_month").text BookingCalendar.local.monthNamesShort[date.getMonth()]

  setHolidays: (day_el, holidays)=>
    day_el.addClass "holiday"
    day_el.find(".fc-day-content").append("<span class='holidays'></span>") if day_el.find(".fc-day-content .holidays").length == 0
    day_el.find(".fc-day-content .holidays").append("#{holiday.name}\n") for holiday in holidays 

  getHolidays: (startDate, endDate, holidays)=>
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
    set = (day_el, el_class, tailId)=>
      day_el.addClass el_class
      @el.find(tailId).remove()
      day_el.children("div").append "<div id='#{tailId}' class='calendar-tail'></div>"
      day_el.find("##{tailId}").show()

    visibleStartDate_el = @getElementByDate moment(@startDate_el.val(), df).toDate()
    visibleEndDate_el = @getElementByDate moment(@endDate_el.val(), df).toDate()
    set $(visibleStartDate_el), "start-date", "calendar-tail-left" if visibleStartDate_el?
    set $(visibleEndDate_el), "end-date", "calendar-tail-right" if visibleEndDate_el?

  resetDay: (day_el)=>
    day_el.removeClass "selected"
    day_el.removeClass "history"
    day_el.removeClass "holiday"
    day_el.find(".fc-day-content > div").text ""
    day_el.find(".holidays").text ""
    day_el.find(".total_quantity").text ""

  resetCalendarView: =>
    @fullcalendar.find(".calendar-tail").remove()
    @fullcalendar.find(".other_month").text ""
    @fullcalendar.find(".closed").removeClass "closed"
    $(".closed-day-alert").remove()

  setSelected: (day_el, date)=>
    startDate = moment(@startDate_el.val(), df).sod().toDate()
    endDate = moment(@endDate_el.val(), df).sod().toDate()
    if date >= startDate && date <= endDate
      day_el.addClass "selected"
    else
      day_el.removeClass "selected"

  selectedPartitions: =>
    if @partitionSelector_el? and @partitionSelector_el.find("option").length and @partitionSelector_el.find("option:selected").val().length
      JSON.parse @partitionSelector_el.find("option:selected").val()
    else
      null

  setQuantityText: (day_el, availableQuantity, totalQuantity)=>
    if @quantityMode is "boolean"
      availableQuantity = if availableQuantity <= 0 then "x" else "✓"
      totalQuantity = if totalQuantity <= 0 then "x" else "✓"
    if @selectedPartitions()?
      day_el.find(".fc-day-content > div").text availableQuantity
      if day_el.find(".fc-day-content .total_quantity").length
         day_el.find(".fc-day-content .total_quantity").text "/#{totalQuantity}"
      else
        day_el.find(".fc-day-content").append "<span class='total_quantity'>/#{totalQuantity}</span>"
     else
      day_el.find(".fc-day-content > div").text totalQuantity

  setAvailability: (day_el, available)=>
    if available or @computeAvailability is false then day_el.removeClass("unavailable").addClass("available") else day_el.removeClass("available").addClass("unavailable")

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
      $(".qtip.target-selection").remove()
      @fullcalendar.find(".selected_for_target_selection").removeClass "selected_for_target_selection"

    $(window).bind "click", => do resetSelection

    @fullcalendar.find(".fc-widget-content").bind "click", (e)=>
      date = @getDateByElement e.currentTarget
      target = $(e.currentTarget)

      if moment(date).sod().diff(moment().sod(), "days") < 0
        do resetSelection
      else if @startDate_el.is ":disabled"
        @endDate_el.val(moment(date).format(df)).change()
      else
        do resetSelection
        target.addClass "selected_for_target_selection"
        content = $.tmpl("tmpl/dialog/calendar/target_selection", {})
        $(content).find("a").bind "click", (e)=>
          if $(e.currentTarget).is ".start_date"
            @startDate_el.val(moment(date).format(df)).change()
          else if $(e.currentTarget).is ".end_date"
            @endDate_el.val(moment(date).format(df)).change()
        target.qtip {content: {text: content}, position: {my: "botom center", at: "top center", viewport: $(window), adjust: { y: -6}}, show: {event: false, ready: true, delay: 0}, style: {classes: "target-selection", tip: {corner: "bottom center"}}, hide: false}

      e.stopPropagation()
      return false

  refreshCulprit: =>
    _.each @lines, (line)=>
      line = $(line)
      av = new App.Availability line.tmplItem().data.availability_for_inventory_pool
      quantity = if @quantity_el.val()? then parseInt(@quantity_el.val()) else line.tmplItem().data.quantity
      unavailableRanges = av.unavailableRanges quantity, @selectedPartitions(), moment(@startDate_el.val(),df), moment(@endDate_el.val(),df)
      text = _.map unavailableRanges, (range) ->
        if range[0] == range[1]
          "#{moment(range[0]).format(df)}"
        else
          "#{moment(range[0]).format(df)} - #{moment(range[1]).format(df)}"
      line.append("<div class='actions'><li class='unavailable_ranges'></li></div>") unless line.find(".unavailable_ranges").length
      line.find(".unavailable_ranges").html(text.join(", ")).attr("title", "unavailable ranges: #{text.join(", ")}")
      line.find(".available .number").html av.maxAvailableForGroups moment(@startDate_el.val(),df), moment(@endDate_el.val(),df), @selectedPartitions()
      line.find(".requested .number").html quantity
      if unavailableRanges.length
        line.addClass("unavailable")
      else
        line.removeClass("unavailable")

window.BookingCalendar = BookingCalendar
df = BookingCalendar.local.dateFormat