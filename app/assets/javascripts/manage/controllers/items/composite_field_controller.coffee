class window.App.CompositeFieldController extends Spine.Controller

  constructor: ->
    super
    if @data.field.label == "Quantity allocations"
      new App.LicenseQuantityPartitionsController {el: @el, data: @data}
