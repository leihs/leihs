class window.App.SwapUsersController extends Spine.Controller

  events:
    "submit form": "submit"

  elements:
    "#errors": "errorsContainer"
    "button[type='submit']": "submitButton"

  constructor: (data)->
    @contract = if data.lines?
      data.lines[0].contract()
    else 
      data.contract
    @modal = new App.Modal App.Render "manage/views/contracts/edit/swap_user_modal", @contract
    @el = @modal.el
    @searchSetUserController = new App.SearchSetUserController { el: @el.find("#user #swapped-person") }
    debugger
    if @contract.user().isDelegation()
      @searchSetContactPersonController = new App.SearchSetUserController
        el: @el.find("#contact-person #swapped-person")
        additionalSearchParams: { delegation_id: @contract.user().id }
    super

  delegateEvents: =>
    super

  submit: (e)->
    e.preventDefault()
    @errorsContainer.addClass "hidden"
    App.Button.disable @submitButton
    if @lines?
      do @swapContractLines
    else
      do @swapContract

  swapContract: =>
    @contract.swapUser(@searchSetUserController.selectedUserId, @searchSetContactPersonController?.selectedUserId)
    .done =>
      window.location.reload(true)
    .fail =>
      @errorsContainer.removeClass "hidden"
      App.Button.enable @submitButton
      @errorsContainer.find("strong").text _jed("Invalid data")

  swapContractLines: =>
    App.ContractLine.swapUser(@lines, @searchSetUserController.selectedUserId)
    .done => 
      window.location = App.User.find(@searchSetUserController.selectedUserId).url("hand_over")
    .fail =>
      @errorsContainer.removeClass "hidden"
      App.Button.enable @submitButton
      @errorsContainer.find("strong").text _jed("Invalid data")
