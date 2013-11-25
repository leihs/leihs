class window.App.ListTabsController extends Spine.Controller

  events: 
    "click .inline-tab-item": "switch"

  constructor: ->
    super

  switch: (e)=>
    target = $ e.currentTarget
    @data = target.data()
    @el.find(".inline-tab-item.active").removeClass "active"
    target.addClass "active"
    do @reset

  getData: => _.clone @data