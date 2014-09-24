class window.App.TemplateController extends Spine.Controller

  constructor: ->
    super
    new App.TemplateModelsController {el: @el.find("#models")}
    new App.InlineEntryRemoveController
      el: @el
