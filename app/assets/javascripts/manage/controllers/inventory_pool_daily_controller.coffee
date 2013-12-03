class window.App.InventoryPoolDailyController extends Spine.Controller
  
  events:
    "click #datepicker": "toggleDatepicker"

  elements:
    "#datepicker-input": "datepickerInput"
    "#daily-navigation": "dailyNavigation"
    "#hand_overs": "handOversContainer"
    "#take_backs": "takeBacksContainer"
    "#workload": "workloadContainer"

  constructor: ->
    super
    @visits = []
    @datepickerOpen = false
    do @fetchData
    new App.LatestReminderTooltipController {el: @el}
    new App.LinesCellTooltipController {el: @el}
    new App.UserCellTooltipController {el: @el}
    new App.HandOversDeleteController {el: @el}
    new App.ContractsApproveController {el: @el}
    new App.TakeBacksSendReminderController {el: @el}
    new App.ContractsRejectController {el: @el, async: true, callback: @orderRejected}

  fetchData: =>
    @fetchHandOvers().done => 
      @fetchUsers().done => @fetchContractLines().done => do @renderHandOvers
    @fetchTakeBacks().done =>
      @fetchUsers().done => @fetchContractLines().done => 
        do @renderTakeBacks
        do @fetchWorkload

  getVisits: => _.compact @handOvers.concat(@takeBacks)

  fetchContractLines: =>
    ids = _.flatten _.map @getVisits(), (v)-> v.contract_line_ids
    return {done: (c)->c()} unless ids.length
    App.ContractLine.ajaxFetch
      data: $.param
        ids: ids

  fetchUsers: =>
    ids = _.filter _.uniq(_.map(@getVisits(), (v)->v.user_id)), (id)-> not App.User.exists(id)?
    if ids.length
      App.User.ajaxFetch
        data: $.param
          ids: ids
          all: true
          paginate: false
    else
      {done: (c)->c()}

  fetchHandOvers: =>
    App.HandOver.ajaxFetch
      data: $.param
        for: "daily_view"
        date: @date
        paginate: false
        date_comparison: 
          if moment(@date).startOf("day").diff(moment().startOf("days"), "days") > 0
            "eq"
          else
            "lteq"
    .done (data) => @handOvers = (App.HandOver.find datum.id for datum in data)

  fetchTakeBacks: =>
    App.TakeBack.ajaxFetch
      data: $.param
        for: "daily_view"
        date: @date
        paginate: false
        date_comparison: 
          if moment(@date).startOf("day").diff(moment().startOf("days"), "days") > 0
            "eq"
          else
            "lteq"
    .done (data) => @takeBacks = (App.TakeBack.find datum.id for datum in data)
        
  fetchWorkload: =>
    return true if @workload?
    App.Workload.ajaxFetch
      data: $.param
        date: @date
    .done (workload) =>
      @workload = new App.Workload(workload)
      do @renderWorkload

  renderHandOvers: => @handOversContainer.find(".list-of-lines").html App.Render "manage/views/hand_overs/line", @handOvers

  renderTakeBacks: => @takeBacksContainer.find(".list-of-lines").html App.Render "manage/views/take_backs/line", @takeBacks

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