###

  ManageBookingCalendar

  This script setups the jquery FullCalendar plugin and adds functionalities

  for booking processes, used for the manage section (managers)

###

class window.App.ManageBookingCalendar extends App.BookingCalendar

  setup: (options)->
    @partitionSelector_el = @el.find "select#booking-calendar-partitions"
    if options.startDateDisabled
      @startDate_el.prop "disabled", true
      @startDate_el.val moment().format("YYYY-MM-DD")
    @lines = options.lines
    @models = options.models
    do @setupPartitionSelector

  getGroupIds: => @partitionSelector_el.find("option:selected").data "value"

  setDayElement: (date, dayElement, holidays)=>
    available = true
    for model in @models
      availability = model.availability().withoutLines(@lines, true)
      requiredQuantity = if @quantity_el.val().length
          parseInt @quantity_el.val() 
        else 
          _.reduce @lines, (mem, l) -> 
            if l.model_id is model.id
              mem+l.quantity 
            else mem
          , 0
      totalQuantity = availability.maxAvailableInTotal(date, date)
      availableQuantity = availability.maxAvailableForGroups date, date, @getGroupIds()
      available = availableQuantity >= requiredQuantity and available
      availableInTotal = totalQuantity >= requiredQuantity and availableInTotal
      
    if @models.length > 1
      @setQuantityText dayElement, (if available then 1 else 0), (if availableInTotal then 1 else 0)
    else
      @setQuantityText dayElement, availableQuantity, totalQuantity

    @setAvailability dayElement, available
    @setSelected dayElement, date

  setQuantityText: (dayElement, availableQuantity, totalQuantity)=>
    if @models.length > 1
      availableQuantity = if availableQuantity <= 0 then "x" else "✓"
      totalQuantity = if totalQuantity <= 0 then "x" else "✓"
    dayElement.find(".fc-day-content > div").text availableQuantity
    if totalQuantity?
      if dayElement.find(".fc-day-content .total_quantity").length
         dayElement.find(".fc-day-content .total_quantity").text "/#{totalQuantity}"
      else
        dayElement.find(".fc-day-content").append "<span class='total_quantity'>/#{totalQuantity}</span>"

  getHolidays: => App.InventoryPool.current.holidays().all()

  setupPartitionSelector: =>
    if @quantity_el.val().length
      return false if not @partitionSelector_el? or @partitionSelector_el.find("option").length == 0
      @partitionSelector_el.find("option:first").select()
      @partitionSelector_el.bind "change", (e)=>
        do @render
    else
      @partitionSelector_el.prop "disabled", true

  selectedPartitions: =>
    if @partitionSelector_el? and @partitionSelector_el.find("option").length and @partitionSelector_el.find("option:selected").val().length
      JSON.parse @partitionSelector_el.find("option:selected").val()
    else
      null

  getInventoryPool: => App.InventoryPool.current

  isClosedDay: (date)=>
    ip = @getInventoryPool()
    super or
      not ip.isVisitPossible(moment(date))
