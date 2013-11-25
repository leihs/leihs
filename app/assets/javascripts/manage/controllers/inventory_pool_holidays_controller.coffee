class window.App.InventoryPoolHolidaysController extends Spine.Controller

  events:
    "click [data-add-holiday]": "addHoliday"
    "click [data-remove-holiday]": "removeHoliday"

  elements:
    "[data-holidays-list]": "holidaysList"

  constructor: ->
    super
    @setupHolidaysDatepickers()

  setupHolidaysDatepickers: =>
    @el.find("#holiday-start-date, #holiday-end-date").datepicker()

  addHoliday: (e) =>
    e.preventDefault()

    start_date = moment(@el.find("#holiday-start-date").val(), i18n.date.L).format("DD.MM.YYYY")
    end_date = moment(@el.find("#holiday-end-date").val(), i18n.date.L).format("DD.MM.YYYY")
    name = @el.find("#holiday-name").val()
    last_holiday_index = _.last(_.sortBy(_.map(@holidaysList.find(".line"), (e) -> $(e).data("index")), (e) -> Number(e)))

    $("[data-holidays-list]").append(App.Render "manage/views/inventory_pools/admin/holiday_entry",
      start_date: start_date
      end_date: end_date
      name: name
      i: if last_holiday_index? then last_holiday_index + 1 else 0)

  removeHoliday: (e) =>
    e.preventDefault()

    line = $(e.currentTarget).closest(".line")
    i = line.data "index"

    if line.find("input[name='inventory_pool[holidays_attributes][#{i}][_destroy]']").length
      line.find(".line-col").removeClass "striked"
      line.find("input[name='inventory_pool[holidays_attributes][#{i}][_destroy]']").remove()
    else
      line.find(".line-col").addClass "striked"
      line.prepend("<input type='hidden' name='inventory_pool[holidays_attributes][#{i}][_destroy]' value='1' />")
