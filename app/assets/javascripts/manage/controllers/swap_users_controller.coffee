class window.App.SwapUsersController extends Spine.Controller

  events:
    "submit form": "submit"
    "delayedChange #user-id": "searchUser"
    "click #remove-user": "removeUser"

  elements:
    "#user-id": "input"
    "#errors": "errorsContainer"
    "button[type='submit']": "submitButton"
    "#selected-user": "selectedUser"

  constructor: (data)->
    @contract = if data.lines?
      data.lines[0].contract()
    else 
      data.contract
    @modal = new App.Modal App.Render "manage/views/contracts/edit/swap_user_modal", @contract
    @el = @modal.el
    @el.find("#user-id").delayedChange {delay: 200}
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
    @contract.swapUser(@selectedUserId)
    .done => 
      window.location.reload(true)
    .fail =>
      @errorsContainer.removeClass "hidden"
      App.Button.enable @submitButton
      @errorsContainer.find("strong").text _jed("Invalid data")

  swapContractLines: =>
    App.ContractLine.swapUser(@lines, @selectedUserId)
    .done => 
      window.location = App.User.find(@selectedUserId).url("hand_over")
    .fail =>
      @errorsContainer.removeClass "hidden"
      App.Button.enable @submitButton
      @errorsContainer.find("strong").text _jed("Invalid data")

  searchUser: ->
    term = @input.val()
    return false if term.length == 0
    App.User.ajaxFetch
      data: $.param
        search_term: term
    .done (data)=> @setupAutocomplete(App.User.find(datum.id) for datum in data)

  setupAutocomplete: (users)->
    @input.autocomplete
      appendTo: @modal.el
      source: (request, response)=> 
        data = _.map users, (u)=>
          u.value = u.id
          u
        response data
      focus: => return false
      select: (e, ui)=> @selectUser(ui.item); return false
    .data("uiAutocomplete")._renderItem = (ul, item) => 
      $(App.Render "manage/views/users/autocomplete_element", item).data("value", item).appendTo(ul)
    @input.autocomplete("search")

  selectUser: (user)->
    @input.hide()
    @input.attr "value", user.id
    @selectedUserId = user.id
    @selectedUser.html App.Render "manage/views/contracts/edit/swapped_user", user

  removeUser: =>
    @input.show().val("").focus()
    @selectedUserId = null
    @selectedUser.html ""