class DailyViewController

  el: "#daily"
  @lists
  
  constructor: ->
    @el = $(@el)
    @lists = @el.find(".list")
    do @render
    do @setupShowMore
    do @plugin

  render: =>
    @el.find(".order .list").append($.tmpl("tmpl/line", json_for_orders)).closest("section").show() if json_for_orders.length
    @el.find(".hand_over .list").append($.tmpl("tmpl/line", json_for_hand_overs)).closest("section").show() if json_for_hand_overs.length
    @el.find(".take_back .list").append($.tmpl("tmpl/line", json_for_take_backs)).closest("section").show() if json_for_take_backs.length

  setupShowMore: =>
    for list in @lists
        list = $(list)
        text = list.parent().find(".tab .text").first().text()
        list.showMore
          min: 4,
          offset:
            top: -36
          more: $.tmpl("app/views/daily_view/_more", {text: text}).html()
          less: $.tmpl("app/views/daily_view/_less", {text: text}).html()

  plugin: =>
    DailyNavigator.setup()

window.App.DailyViewController = DailyViewController
