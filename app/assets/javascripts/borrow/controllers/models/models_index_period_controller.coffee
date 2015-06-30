class window.App.ModelsIndexPeriodController extends Spine.Controller

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
    "preChange #start-date": "selectStartDate"
    "preChange #end-date": "selectEndDate"

  constructor: ->
    super
    do @setupStartDate
    do @setupEndDate

  setupStartDate: ->
    @startDate.datepicker
      onSelect: @selectStartDate
      minDate: moment().toDate()
    @startDate.preChange()

  selectStartDate: ()=>
    date = moment(@startDate.val(), i18n.date.L)
    return false unless moment(date).isValid()
    if not @endDate.val()? or not @endDate.val().length or date.diff(moment(@endDate.val(), i18n.date.L), "days") >= 0
      @endDate.val(date.add(1, "days").format(i18n.date.L))
    @endDate.datepicker "option", "minDate", moment(date, i18n.date.L).toDate()
    @startDate.trigger "change"
    do @onChange

  setupEndDate: =>
    @endDate.datepicker
      onSelect: @selectEndDate
      minDate: moment().toDate()
    @endDate.preChange()

  selectEndDate: ()=>
    date = moment(@endDate.val(), i18n.date.L)
    return false unless moment(date).isValid()
    if not @startDate.val()? or not @startDate.val().length
      @startDate.val(date.subtract(1, "days").format(i18n.date.L))
    @endDate.trigger "change"
    do @onChange

  getPeriod: =>
    if @startDate.val().length and @endDate.val().length
      {start_date: moment(@startDate.val(), i18n.date.L).format("YYYY-MM-DD"), end_date: moment(@endDate.val(), i18n.date.L).format("YYYY-MM-DD")}

  validate: => 
    if @startDate.val().length == 0 or @endDate.val().length == 0
      do @onChange

  reset: =>
    @startDate.val null
    @endDate.val null
    App.PlainAvailability.deleteAll()

  is_resetable: => @getPeriod()?