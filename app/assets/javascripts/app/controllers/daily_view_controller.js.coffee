class DailyViewController

  el: "#daily"
  
  constructor: (options)->
    @el = $(@el)
    @lists = @el.find(".list")
    @date = moment(options.date).toDate() if options.date?
    do @setupOrders
    do @setupHandOvers
    do @setupTakeBacks
    do @setupWorkload
    do @plugin

  date_to_s: => moment(@date).format("YYYY-MM-DD")

  setupOrders: =>
    $.ajax
      url: "/backend/inventory_pools/#{currentInventoryPool.id}/contracts.json"
      type: "GET"
      cache: false
      data:
        filter: "pending"
        paginate: false
      success: (data)=>
        @el.find(".order .badge").text data.length
        @el.find(".order .list").append($.tmpl("tmpl/line", data)).closest("section").show() if data.length
        @setupShowMore @el.find(".order .list")

  setupHandOvers: =>
    $.ajax
      url: "/backend/inventory_pools/#{currentInventoryPool.id}/visits.json"
      type: "GET"
      cache: false
      data: 
        filter: "hand_over"
        date: @date_to_s()
        paginate: false
      success: (data)=>
        @el.find(".hand_over .badge").text data.length
        @el.find(".hand_over .list").append($.tmpl("tmpl/line", data)).closest("section").show() if data.length
        @setupShowMore @el.find(".hand_over .list")

  setupTakeBacks: =>
    $.ajax
      url: "/backend/inventory_pools/#{currentInventoryPool.id}/visits.json"
      type: "GET"
      cache: false
      data: 
        filter: "take_back"
        date: @date_to_s()
        paginate: false
        with:
          latest_remind: true
      success: (data)=>
        @el.find(".take_back .badge").text data.length
        @el.find(".take_back .list").append($.tmpl("tmpl/line", data)).closest("section").show() if data.length
        @setupShowMore @el.find(".take_back .list")
    
  setupShowMore: (list)=>
    list.showMore
      min: 4,
      offset:
        top: -36
      more: $.tmpl("app/views/daily_view/_more").html()
      less: $.tmpl("app/views/daily_view/_less").html()

  setupWorkload: =>
    $.ajax
      url: "/backend/inventory_pools/#{currentInventoryPool.id}/workload.json"
      type: "GET"
      cache: false
      data: 
        date: @date_to_s()
      success: (data)=>
        $("#chart .barchart").jqBarGraph
          data: data,
          colors: ['#999999','#cccccc'],
          width: 960,
          height: 300,
          barSpace: 105,
          animate: false,
          interGrids: 0

  plugin: =>
    DailyNavigator.setup()

window.App.DailyViewController = DailyViewController
