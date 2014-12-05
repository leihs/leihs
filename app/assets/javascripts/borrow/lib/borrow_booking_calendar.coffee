###

  BorrowBookingCalendar

  This script setups the jquery FullCalendar plugin and adds functionalities

  for booking processes, used for the borrow section (customers)

###

class window.App.BorrowBookingCalendar extends App.BookingCalendar

  setup: (options)->
    @ipSelector_el = if options.ipSelectorEl? then options.ipSelectorEl else @el.find("select#inventory_pool_id")
    do @setupInventoryPoolSelector

  getAvailability: => @ipSelector_el.find("option:selected").data "availability"

  getGroupIds: => @groupIds

  setDayElement: (date, dayElement, holidays)=>
    requiredQuantity = parseInt @quantity_el.val()
    availableQuantity = @getAvailability().maxAvailableForGroups date, date, @getGroupIds()
    available = availableQuantity >= requiredQuantity
    if not @isClosedDay(date) and not holidays.length
      @setQuantityText dayElement, availableQuantity
    @setAvailability dayElement, available
    @setSelected dayElement, date

  setQuantityText: (dayElement, availableQuantity)=>
    dayElement.find(".fc-day-content > div").text availableQuantity

  getHolidays: => @ipSelector_el.find("option:selected").data("holidays")

  setupInventoryPoolSelector: =>
    @ipSelector_el.find("option:first").select()
    @ipSelector_el.bind "change", =>
      av = @ipSelector_el.find("option:selected").data "availability"
      @setMaxQuantity av.total_borrowable
      do @render
    @ipSelector_el.change()

  getInventoryPool: => App.InventoryPool.find @ipSelector_el.find("option:selected").data("id")

  isClosedDay: (date)=>
    ip = @getInventoryPool()
    super or
      not ip.isVisitPossible(moment(date)) or
      not ip.hasEnoughReservationAdvanceDays(date)
