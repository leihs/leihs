class DailyViewController

  el: "#inventory"
  @lists
  
  constructor: ->
    @el = $(@el)
    @lists = @el.find(".list")
    do @render
    do @setupShowMore
    do @plugin

  render: =>
    @el.find(".list").hide()
    @el.find(".order .list").append $.tmpl("tmpl/line", json_for_orders)
    @el.find(".hand_over .list").append $.tmpl("tmpl/line", json_for_hand_overs)
    @el.find(".take_back .list").append $.tmpl("tmpl/line", json_for_take_backs)

  setupShowMore: =>
    for list in @lists
        text = list.parent().find(".tab .text").first().text()
        list.showMore
          min: 4,
          offset:
            top: -36
          more: $tmpl("app/views/daily_view/_more", {text: text}) 
          less: $tmpl("app/views/daily_view/_less", {text: text})

  plugin: =>
    DailyNavigator.setup()


window.App.DailyViewController = DailyViewController
