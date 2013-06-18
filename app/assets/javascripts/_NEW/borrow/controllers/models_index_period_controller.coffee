class window.App.Borrow.ModelsIndexPeriodController extends Spine.Controller

  elements:
    "#start-date": "startDate"
    "#end-date": "endDate"

  events:
    "keydown #start-date": "validate"
    "keydown #end-date": "validate"
    "mousedown #start-date": "validate"
    "mousedown #end-date": "validate"
    "change #start-date": "validate"
    "change #end-date": "validate"

  constructor: ->
    super
    do @setupStartDate
    do @setupEndDate

  setupStartDate: ->
    @startDate.datepicker
      onSelect: @selectStartDate
      minDate: moment().toDate()

  selectStartDate: (date)=>
    if not @endDate.val()? or not @endDate.val().length or moment(date, i18n.date.L).diff(moment(@endDate.val(), i18n.date.L), "days") >= 0
      @endDate.val(moment(date, i18n.date.L).add("days", 1).format(i18n.date.L))
    @endDate.datepicker "option", "minDate", moment(date, i18n.date.L).toDate()
    @startDate.trigger "change"
    do @onChange

  setupEndDate: =>
    @endDate.datepicker
      onSelect: @selectEndDate
      minDate: moment().toDate()

  selectEndDate: (date)=>
    if not @startDate.val()? or not @startDate.val().length
      @startDate.val(moment(date, i18n.date.L).subtract("days", 1).format(i18n.date.L))
    @endDate.trigger "change"
    do @onChange

  getPeriod: =>
    if @startDate.val().length and @endDate.val().length
      {start_date: moment(@startDate.val(), i18n.date.L).format("YYYY-MM-DD"), end_date: moment(@endDate.val(), i18n.date.L).format("YYYY-MM-DD")}

  validate: => 
    if @startDate.val().length == 0 or @endDate.val().length == 0
      do @onChange
