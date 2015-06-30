class window.App.ListRangeController extends Spine.Controller

  elements:
    "input[name='start_date']": "startDate"
    "input[name='end_date']": "endDate"

  events:
    "change input[name='start_date']": "changedStartDate"
    "change input[name='end_date']": "changedEndDate"

  constructor: ->
    super
    do @setupInputs

  setupInputs: =>
    for input in [@startDate, @endDate]
      if $(input).val().length
        $(input).val moment($(input).val()).format(i18n.date.XS)
      $(input).datepicker
        dateFormat: i18n.datepicker.XS

  get: =>
    data = {}
    data.start_date = @getStartDate().format("YYYY-MM-DD") if @getStartDate()?
    data.end_date = @getEndDate().format("YYYY-MM-DD") if @getEndDate()?
    return data

  getStartDate: =>
    moment(@startDate.val(), i18n.date.XS) unless @startDate.val() == ""

  getEndDate: =>
    moment(@endDate.val(), i18n.date.XS) unless @endDate.val() == ""

  changedStartDate: => do @reset

  changedEndDate: => do @reset