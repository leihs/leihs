class window.App.InventoryPoolDailyController extends Spine.Controller
  
  events:
    "click #datepicker": "toggleDatepicker"

  elements:
    "#datepicker-input": "datepickerInput"
    "#daily-navigation": "dailyNavigation"
    "#workload": "workloadContainer"

  constructor: ->
    super
    @visits = []
    @datepickerOpen = false
    do @fetchData
    new App.LatestReminderTooltipController {el: @el}

  fetchData: =>
    do @fetchWorkload

  fetchWorkload: =>
    return true if @workload?
    App.Workload.ajaxFetch
      data: $.param
        date: @date
    .done (workload) =>
      @workload = new App.Workload(workload)
      do @renderWorkload

  renderWorkload: =>
    @workloadContainer.html App.Render "manage/views/inventory_pools/daily/workload"
    @workloadContainer.find(".bar-chart").jqBarGraph
      data: @workload.data,
      colors: ['#999999','#cccccc'],
      gridColors: ['#bbbbbb','#dddddd'],
      width: 960,
      height: 300,
      barSpace: 105,
      animate: false,
      interGrids: 0

  toggleDatepicker: =>
    unless @datepicker?
      @datepicker = @datepickerInput.datepicker
        defaultDate: moment(@date).toDate()
        onSelect: (dateText, inst)=>
          uri = URI(window.location.href).removeQuery("date").addQuery("date", moment(dateText,i18n.date.L).format("YYYY-MM-DD"))
          window.location = uri
    @datepickerOpen = !@datepickerOpen
    if @datepickerOpen
      @datepickerInput.focus()
    else
      @datepickerInput.datepicker("hide")


  updateNavigationLinks: (e, tabTarget)=>
    for el in @dailyNavigation.find("a[href]")
      el = $(el)
      uri = URI(el.attr("href")).removeQuery("tab").addQuery("tab", tabTarget)
      el.attr "href", uri