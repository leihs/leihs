class window.App.TemplateAvailabilityController extends Spine.Controller

  elements:
    "#template-lines": "templateLines"

  events:
    "click [data-change-template-line]": "changeTemplateLine"
    "click [data-destroy-template-line]": "destroyTemplateLine"

  delegateEvents: ->
    super
    App.TemplateLine.on "change", @render

  changeTemplateLine: (e)=>
    do e.preventDefault
    target = $(e.currentTarget)
    line = target.closest(".line")
    templateLine = App.TemplateLine.findByAttribute("model_link_id", line.data("model_link_id"))
    new App.TemplateLineChangeController
      modelId: target.data("model-id")
      quantity: target.data("quantity")
      startDate: target.data("start-date")
      endDate: target.data("end-date")
      titel: _jed("Change %s", _jed("Entry"))
      buttonText: _jed("Save change")
      templateLine: templateLine
    return false

  destroyTemplateLine: (e)=>
    do e.preventDefault
    target = $(e.currentTarget)
    line = target.closest(".line")
    templateLine = App.TemplateLine.findByAttribute("model_link_id", line.data("model_link_id"))
    if confirm _jed "%s will be removed from the template and not been added to your order.", templateLine.model().name()
      App.TemplateLine.destroy templateLine.id
      if @templateLines.find(".line").length == 0
        document.location = "/borrow/templates"
    return false

  render: =>
    @templateLines.html App.Render "borrow/views/templates/availability/grouped_lines", App.Template.first().groupedLines()