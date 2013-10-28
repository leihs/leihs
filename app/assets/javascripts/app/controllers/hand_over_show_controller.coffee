class HandOverShowController extends App.GroupsController

  constructor: (options)->
    @el = options.el
    @inner = @el.find "#hand_over_inner"
    App.HandOver.ajaxFetch().done (data)=>
      @visits = data
      do @render

  render: ->
    @inner.show()
    $('#visits').html $.tmpl("tmpl/visit", @visits)
    HandOver.setup()
    ProcessHelper.setup()
    SelectedLines.setup()
  
window.App.HandOverShowController = HandOverShowController
