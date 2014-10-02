class window.App.LicenseQuantityPartitionsController extends Spine.Controller

  events:
    "click #add-inline-entry": "add"
    "preChange [data-quantity-allocation]": "updateRemainingQuantity"

  elements:
    "#remaining-total-quantity": "remainingQuantityElement"

  constructor: ->
    super
    @el.append "<div class='row list-of-lines even'></div>"
    @list = @el.find ".list-of-lines"
    @dataSourceElement = $(".field[data-id='#{@data.field.data_dependency_field_id}'] [data-type='value'] input").preChange()
    @dataSourceElement.on "preChange", @updateRemainingQuantity
    @allocations = @data.itemData.properties.quantity_allocations
    @render(@allocations)
    @allocationElements = @el.find("[data-quantity-allocation]").preChange()
    @updateRemainingQuantity()
    new App.InlineEntryRemoveController
      el: @list
      removeCallback: (entry) =>
        @allocationElements =
          _.reject \
            (_.map @allocationElements, $), # sometimes the elements are not jquery objects, thus wrapping them here. if they are already wrapped, they remain so.
            (el) -> el.get(0) == entry.find("[data-quantity-allocation]").get(0) # with get(0) we unwrap the dom element inside the jquery object
        @updateRemainingQuantity()
      strikeCallback: (entry) -> @removeCallback(entry)
      unstrikeCallback: (entry) =>
        @allocationElements.push entry.find("[data-quantity-allocation]")
        @updateRemainingQuantity()

  registerEventHandlers: =>

  add: (e) =>
    e.preventDefault()
    lineElement = $(App.Render "manage/views/items/fields/writeable/composite_partials/license_quantity_allocation", {field: @data.field})
    @list.prepend lineElement
    lineElement.data("new", true)
    @allocationElements.push lineElement.find("[data-quantity-allocation]").preChange()

  render: (allocations) =>
    if allocations
      for allocation in allocations
        @list.append App.Render "manage/views/items/fields/writeable/composite_partials/license_quantity_allocation", {field: @data.field, allocation: allocation}

  getRemainingQuantity: =>
    dataSourceValue = parseInt @dataSourceElement.val()
    (if _.isNaN(dataSourceValue) then 0 else dataSourceValue) -
      _.reduce \
        ( _.map \
            @allocationElements,
            (el) ->
              v = parseInt $(el).val()
              if _.isNaN(v) then 0 else v ),
        (memo, num) -> memo + num,
        0

  updateRemainingQuantity: =>
    @remainingQuantityElement.text("#{_jed 'remaining'} #{@getRemainingQuantity()}")
