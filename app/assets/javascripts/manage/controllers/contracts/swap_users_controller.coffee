class window.App.SwapUsersController extends Spine.Controller

  events:
    "submit form": "submit"

  elements:
    "form": "form"
    "#errors": "errorsContainer"
    "button[type='submit']": "submitButton"

  constructor: (data)->
    @contract = if data.reservations?
      data.reservations[0].contract()
    else 
      data.contract
    @modal = new App.Modal App.Render "manage/views/contracts/edit/swap_user_modal", @contract
    @el = @modal.el
    super

    @searchSetUserController = new App.SearchSetUserController
      el: @el.find("#user #swapped-person")
      selectCallback: if @manageContactPerson then => @setupContactPerson() else null

    @setupContactPerson() if @manageContactPerson

  delegateEvents: =>
    super

  submit: (e)->
    e.preventDefault()
    @errorsContainer.addClass "hidden"
    App.Button.disable @submitButton
    if @reservations?
      do @swapReservations
    else
      do @swapContract

  swapContract: =>
    @contract.swapUser(@searchSetUserController.selectedUserId, @searchSetContactPersonController?.selectedUserId)
    .done (data)=>
      contract = new App.Contract data
      window.location = contract.editPath()
    .fail (e) =>
      @errorsContainer.removeClass "hidden"
      App.Button.enable @submitButton
      @errorsContainer.find("strong").text e.responseText

  swapReservations: =>
    App.Reservation.swapUser(@reservations, @searchSetUserController.selectedUserId)
    .done => 
      window.location = App.User.find(@searchSetUserController.selectedUserId).url("hand_over")
    .fail =>
      @errorsContainer.removeClass "hidden"
      App.Button.enable @submitButton
      @errorsContainer.find("strong").text _jed("Invalid data")

  renderContactPerson: => @form.append App.Render "manage/views/contracts/edit/contact_person", @contract

  setupContactPerson: =>
    @el.find("#contact-person").remove()
    @searchSetContactPersonController = null
    user_id = @searchSetUserController.selectedUserId ? @contract.user().id
    if App.User.find(user_id).isDelegation()
      @renderContactPerson()
      App.User.ajaxFetch
        data: $.param
          delegation_id: user_id
      .done (data) =>
        @searchSetContactPersonController = new App.SearchSetUserController
          el: @el.find("#contact-person #swapped-person")
          localSearch: true
          customAutocompleteOptions:
            source: ( $.extend App.User.find(datum.id), { label: datum.name } for datum in data )
            minLength: 0
