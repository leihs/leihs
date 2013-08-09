class window.App.Borrow.TemplatesShowController extends Spine.Controller

  elements:
    "#start_date": "startDateEl"
    "#end_date": "endDateEl"
    "input[name='start_date']": "startDate"
    "input[name='end_date']": "endDate"

  events: 
    "change #start_date": "onChangeStartDate"
    "change #end_date": "onChangeEndDate"
    "change input[type='number']": "validateNumber"
    "delayedChange input[type='number']": "validateNumber"

  constructor: ->
    super
    do @setupNumbers
    do @setupDates

  setupDates: =>
    @endDateEl.val moment(@endDate.val(), "YYYY-MM-DD").format(i18n.date.L)
    @endDateEl.datepicker().change()
    @startDateEl.val moment(@startDate.val(), "YYYY-MM-DD").format(i18n.date.L)
    @startDateEl.datepicker().change()
    @startDateEl.datepicker "option", "minDate", moment().toDate()

  setupNumbers: =>
    @el.find("input[type='number']").delayedChange()

  onChangeStartDate: =>
    @startDate.val moment(@startDateEl.val(), i18n.date.L).format("YYYY-MM-DD")
    @endDateEl.datepicker "option", "minDate", moment(@startDate.val()).toDate()
    if moment(@endDate.val()).diff(moment(@startDate.val()), "days") < 0
      @endDate.val @startDate.val()

  onChangeEndDate: =>
    @endDate.val moment(@endDateEl.val(), i18n.date.L).format("YYYY-MM-DD")

  validateNumber: (e)=>
    target = $(e.currentTarget)
    if parseInt(target.val()) > parseInt(target.attr("max"))
      target.val(target.attr("max"))
    else if parseInt(target.val()) < parseInt(target.attr("min"))
      target.val(target.attr("min"))
    else if target.val().match(/\D/)
      target.val(target.attr("min"))
