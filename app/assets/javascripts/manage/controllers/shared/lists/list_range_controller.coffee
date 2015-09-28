class window.App.ListRangeController extends Spine.Controller

  elements:
    "input[name='start_date']": "startDate"
    "input[name='end_date']": "endDate"
    "input[name='before_last_check']": "beforeLastCheck"

  events:
    "change input[name='start_date']": "reset"
    "change input[name='end_date']": "reset"
    "change input[name='before_last_check']": "reset"

  constructor: ->
    super
    do @setupInputs

  setupInputs: =>
    for input in [@startDate, @endDate, @beforeLastCheck]
      if $(input).length
        if $(input).val().length
          $(input).val moment($(input).val()).format(i18n.date.L)
        $(input).datepicker
          dateFormat: i18n.datepicker.L

  get: =>
    data = {}
    data.start_date = @getStartDate().format("YYYY-MM-DD") if @getStartDate()?
    data.end_date = @getEndDate().format("YYYY-MM-DD") if @getEndDate()?
    data.before_last_check = @getBeforeLastCheck().format("YYYY-MM-DD") if @getBeforeLastCheck()?
    return data

  getStartDate: =>
    moment(@startDate.val(), i18n.date.L) unless @startDate.val() == ""

  getEndDate: =>
    moment(@endDate.val(), i18n.date.L) unless @endDate.val() == ""

  getBeforeLastCheck: =>
    moment(@beforeLastCheck.val(), i18n.date.L) unless @beforeLastCheck.val() == ""
