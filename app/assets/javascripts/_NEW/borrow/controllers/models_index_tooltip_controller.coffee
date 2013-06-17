class window.App.Borrow.ModelsIndexTooltipController extends Spine.Controller

  events:
    "mouseleave .line[data-id]": "leaveLine"
    "mouseenter .line[data-id]": "enterLine"

  tooltips: {}

  delegateEvents: =>
    super
    App.Property.on "refresh", =>
      for model_id, tooltip of @tooltips
        unless tooltip.content?
          do (model_id, tooltip)=>
            model = App.Model.find(model_id)
            model.propertiesToDisplay = _.first model.properties().all(), 5
            model.amount_of_images = 3
            content = App.Render "borrow/views/models/index/tooltip", model
            @preloadImages content, model, =>
              tooltip.update App.Render "borrow/views/models/index/tooltip", model
              do tooltip.enable
              do tooltip.show if @currentTooltip == tooltip

  createTooltip: (line) =>
    new App.Tooltip
      el: line

  fetchProperties: (model_ids) =>
    App.Property.fetch
      data: $.param
        model_ids: model_ids

  enterLine: (e) =>
    target = $(e.currentTarget)
    model_id = target.data('id')
    @mouseOverTooltip = true
    unless @tooltips[model_id]?
      tooltip = @createTooltip target
      do tooltip.disable
      @currentTooltip = tooltip
      @tooltips[model_id] = tooltip
      @fetchProperties [model_id]
    else
      @currentTooltip = @tooltips[model_id]

  leaveLine: (e) => @mouseOverTooltip = false

  preloadImages: (content, model, update)=>
    errors = 0
    amountOfImages = $(content).find("img").length
    update = _.after amountOfImages, update
    $(content).find("img").one "error", (e)=> 
      errors++
      model.amount_of_images--
    $(content).find("img").one "load error", update