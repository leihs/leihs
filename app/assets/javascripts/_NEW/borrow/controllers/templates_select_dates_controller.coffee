class window.App.Borrow.TemplatesSelectDatesController extends Spine.Controller

  elements:
    "#start_date": "startDateEl"
    "#end_date": "endDateEl"
    "input[name='start_date']": "startDate"
    "input[name='end_date']": "endDate"

  events: 
    "change #start_date": "onChangeStartDate"
    "change #end_date": "onChangeEndDate"

  constructor: ->
    super
    do @setupDates

  setupDates: =>
    @endDateEl.val moment(@endDate.val(), "YYYY-MM-DD").format(i18n.date.L)
    @endDateEl.datepicker().change()
    @startDateEl.val moment(@startDate.val(), "YYYY-MM-DD").format(i18n.date.L)
    @startDateEl.datepicker().change()
    @startDateEl.datepicker "option", "minDate", moment().toDate()

  onChangeStartDate: =>
    @startDate.val moment(@startDateEl.val(), i18n.date.L).format("YYYY-MM-DD")
    @endDateEl.datepicker "option", "minDate", moment(@startDate.val()).toDate()
    if moment(@endDate.val()).diff(moment(@startDate.val()), "days") < 0
      @endDate.val @startDate.val()

  onChangeEndDate: =>
    @endDate.val moment(@endDateEl.val(), i18n.date.L).format("YYYY-MM-DD")