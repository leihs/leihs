class window.App.ContractsEditController extends Spine.Controller

  elements:
    "#status": "status"
    "#lines": "reservationsContainer"
    "#purpose": "purposeContainer"
    "#reject-contract": "rejectButton"
    "#approve-contract": "approveButton"

  events:
    "click #edit-purpose.button": "editPurpose"
    "click #swap-user": "swapUser"
    "click #approve-with-comment": "approveContractWithComment"
    "click [data-destroy-line]": "validateLineDeletion"
    "click [data-destroy-lines]": "validateLineDeletion"
    "click [data-destroy-selected-lines]": "validateLineDeletion"

  constructor: ->
    super 
    do @setupLineSelection
    do @fetchAvailability
    do @setupAddLine
    new App.SwapModelController {el: @el}
    new App.TimeLineController {el: @el}
    new App.ContractsApproveController {el: @el, done: @contractApproved}
    new App.ContractsRejectController {el: @el, async: false}
    new App.ReservationsDestroyController {el: @el}
    new App.ReservationsEditController {el: @el, user: @contract.user(), contract: @contract}
    new App.ModelCellTooltipController {el: @el}

  delegateEvents: =>
    super
    App.Purpose.on "update", @renderPurpose
    App.Reservation.on "change destroy", @fetchAvailability
    App.Contract.on "refresh", @fetchAvailability

  setupAddLine: =>
    that = @

    reservationsAddController = new App.ReservationsAddController
      el: @el.find("#add")
      user: @contract.user()
      status: @status
      contract: @contract
      purpose: @purpose
      modelsPerPage: 20

    onChangeCallback = (value) ->
      console.log 'onChangeCallback'
      that.inputValue = value
      that.autocompleteController.setProps(isLoading: true)
      reservationsAddController.search value, (data)->
        that.autocompleteController.setProps(searchResults: data, isLoading: false)

    # create and mount the input field:
    props =
      onChange: _.debounce(onChangeCallback, 300)
      onSelect: reservationsAddController.select
      isLoading: false
      placeholder: _jed("Inventory code, model name, search term")

    @autocompleteController =
      new App.HandOverAutocompleteController \
        props,
        @el.find("#add-input")[0]

    @autocompleteController._render()

    window.autocompleteController = @autocompleteController

    reservationsAddController.setupAutocomplete(@autocompleteController)

  setupLineSelection: =>
    @lineSelection = new App.LineSelectionController
      el: @el

  validateLineDeletion: (e)=>
    ids = if $(e.currentTarget).closest("[data-id]").length
        [$(e.currentTarget).closest("[data-id]").data("id")]
      else if $(e.currentTarget).data("ids")?
        $(e.currentTarget).data("ids")
      else
        App.LineSelectionController.selected
    if @contract.reservations().all().length <= ids.length
      App.Flash
        type: "error"
        message: _jed "You cannot delete all reservations of an contract. Perhaps you want to reject it instead?"
      e.stopImmediatePropagation()
      return false

  fetchAvailability: =>
    @render false
    @status.html App.Render "manage/views/availabilities/loading"
    App.Availability.ajaxFetch
      data: $.param
        model_ids: _.uniq(_.map(@contract.reservations().all(), (l)->l.model().id))
        user_id: @contract.user_id
    .done (data)=>
      @status.html App.Render "manage/views/availabilities/loaded"
      @render true

  render: (renderAvailability)=> 
    @reservationsContainer.html App.Render "manage/views/reservations/grouped_lines", @contract.groupedLinesByDateRange(true),
      linePartial: "manage/views/reservations/order_line"
      renderAvailability: renderAvailability
    do @lineSelection.restore

  editPurpose: =>
    new App.ContractsEditPurposeController
      purpose: @purpose

  swapUser: =>
    new App.SwapUsersController
      contract: @contract
      manageContactPerson: true

  renderPurpose: => @purposeContainer.html @purpose.description

  approveContractWithComment: =>
    new App.ContractsApproveWithCommentController
      trigger: @approveButton
      contract: @contract

  contractApproved: =>
    window.location = "/manage/#{App.InventoryPool.current.id}/daily?flash[success]=#{_jed('Order approved')}"
